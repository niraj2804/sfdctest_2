public with sharing class sendautomatedWAmessage {
    @InvocableMethod(label='Birthday WAMessage')
    public static void invokeThisMethod(List<FlowInputs> request) {
        String message1 = sendautomatedWAmessage.method1(request[0].templatebody, request[0].recordId);
        WhatsAppController.sendTemplateMessage(request[0].recordId,message1,request[0].WANumber);     
    }
    public class FlowInputs{
        @InvocableVariable(required=True)
        public Id recordId;
        
        @InvocableVariable(required=True)
        public String templatebody;
        
        @InvocableVariable(required=True)
        public String WANumber;
        
        //@InvocableVariable(required=True)
        //public String objapiname;
    }
    public static String method1(String templatebody,Id recordId){
        //String str = 'Hello, this is {{FirstName}} {{LastName}}';
        pattern p = pattern.compile('\\{(.*?)\\}');
        Matcher m = p.matcher(templatebody);
        String objapiname = String.valueOf(recordId.getsobjecttype());
        List<String> l1 = new List<String>(); //for adding values of object fields
        List<String> l2 = new List<String>(); //for field names
        String QueryFields = '';
        while(m.find()) {
            String a = m.group().substring( 2, m.group().length() - 1);
            l2.add(a);
            QueryFields = QueryFields + a +',';
            System.debug( m.group().substring( 2, m.group().length() - 1) );
        }
        String contactQuery = 'SELECT ' +QueryFields + 'Id FROM '+objapiname+' WHERE Id =:recordId';
        List<sObject> conList = Database.query(contactQuery);
        for(Integer i=0;i<l2.size();i++){
            String b = (String)conList[0].get(l2.get(i));
            l1.add(b);
        }
        System.debug('List1: '+l1);
        System.debug('List2: '+l2);
        for(Integer i=0;i<l2.size();i++){
            templatebody = templatebody.replace( '{{'+l2.get(i)+'}}' , l1.get(i));
        }
        System.debug('final string: '+templatebody);
        return templatebody;
    }
}