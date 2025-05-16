public with sharing class filesenderController {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> FilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs ORDER BY CreatedDate DESC];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
    @AuraEnabled
    public static Boolean sendfile (String contentdocid,String recordId,String num1){
        List<ContentDistribution> lstlinks = [SELECT Id, Name, ContentVersionId, ContentDocumentId, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =:contentdocid];
        System.debug('link: '+lstlinks.get(0).ContentDownloadUrl);
        return WhatsAppController.sendsinglefile(contentdocid,recordId, lstlinks.get(0).ContentDownloadUrl,lstlinks.get(0).Name,num1);
    }
    //for fetching map of id and Name for sending WAMsgTemplates.
    @AuraEnabled(cacheable=true)
    public static Map<Id, String> fetchtemplates(){
        List<WAMsgTemplate__c> watemplist = [SELECT Id,Name FROM WAMsgTemplate__c LIMIT 5];
        Map<ID, String> mapIdName = new Map<ID, String>();
        for(WAMsgTemplate__c watemp : watemplist) {
            mapIdName.put(watemp.Id, watemp.Name);
        }
        return mapIdName;
    }
    
    @AuraEnabled(cacheable=true) 
    public static String method1(String templatebody,String recordId,String objapi1){
        //String str = 'Hello, this is {{FirstName}} {{LastName}}';
        pattern p = pattern.compile('\\{(.*?)\\}');
        Matcher m = p.matcher(templatebody);
        //String objapiname = String.valueOf(recordId.getsobjecttype());
        String objapiname = objapi1;
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
    @AuraEnabled(cacheable=true)
    public static String sendonetemplate(String templId, String recordId,String num1){
        List<WAMsgTemplate__c> msgbodylist = [SELECT Id, MessageBody__c,ObjectAPIName__c FROM WAMsgTemplate__c WHERE Id =:templId];
        String msgbody1 = msgbodylist.get(0).MessageBody__c;
        String objapi = msgbodylist.get(0).ObjectAPIName__c;
		String message1 = filesenderController.method1(msgbody1, recordId,objapi);
       	//Boolean status = WhatsAppController.sendTemplateMessage(recordId,message1,num1); 
        return message1;
    }
    
}