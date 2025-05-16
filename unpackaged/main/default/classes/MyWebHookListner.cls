@RestResource(urlMapping='/hookin')
global class MyWebHookListner {
	@HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String verify_token = req.params.get('hub.verify_token');
        if(verify_token == 'hello'){
            res.responseBody = blob.valueOf(req.params.get('hub.challenge'));
        }
    }
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
		System.debug('req.requestBody : '+req.requestBody.toString());
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        List<Object> entrylst = (List<Object>)params.get('entry');
        Map<String, Object> entrydata1 = (Map<String, Object>) entrylst[0];
        List<Object> changeslst = (List<Object>) entrydata1.get('changes');
        Map<String, Object> changesdata1 = (Map<String, Object>) changeslst[0];
        Map<String, Object> valuedata = (Map<String, Object>) changesdata1.get('value');
        if(valuedata != null && valuedata.get('messages') != null){
        	List<Object> msglst = (List<Object>) valuedata.get('messages');
            //List<Object> msglst = (List<Object>)valuedata.get('messages');
            Map<String, Object> msgdata = (Map<String, Object>) msglst[0];
            //Map<String, Object> from_num = (Map<String, Object>) msgdata.get('from');  //from number
            String from_num = (String) msgdata.get('from');
            String wamsgid = (String) msgdata.get('id');
            Map<String, Object> textdata = (Map<String, Object>) msgdata.get('text');
            //Map<String, Object> msg_text = (Map<String, Object>) msgdata.get('body');  //message text
            String msg_text = (String) textdata.get('body');
            System.debug('from number is: '+ from_num);
            System.debug('message text is: '+msg_text); 
            String fromNumWithCode =  from_num.substring(2, 12);
            System.debug('from number is: '+fromNumWithCode);
            List<Contact> lstContact = [SELECT Id FROM Contact WHERE (Phone =:from_num OR MobilePhone=:from_num OR HomePhone=:from_num OR OtherPhone=:from_num OR AssistantPhone=:from_num) OR Phone =:fromNumWithCode LIMIT 1];
            
            if(lstContact != null && lstContact.size()> 0){
                WAMessage__c wamsg = new WAMessage__c();
                wamsg.Message__c=msg_text;
                wamsg.Type__c='Incoming';
                wamsg.isIncoming__c = true;
            	wamsg.Contact__c=lstContact.get(0).Id;
                wamsg.WAMid__c = wamsgid;
                wamsg.Phone_Number__c = fromNumWithCode;
				insert wamsg;
                
                WhatsappMessageEvent__e event = new WhatsappMessageEvent__e(RecordId__c = lstContact.get(0).Id);
                Database.SaveResult result = EventBus.publish(event);
            }
        }
        else if(valuedata != null && valuedata.get('statuses') != null){
            List<Object> statuseslist = (List<Object>) valuedata.get('statuses');
            Map<String, Object> statusdata = (Map<String, Object>) statuseslist[0];
            String current_status = (String) statusdata.get('status');
            String wamsgid = (String) statusdata.get('id');
            System.debug('current status is: '+current_status);
            List<WAMessage__c> wamsglist = [SELECT Id FROM WAMessage__c WHERE WAMid__c=:wamsgid LIMIT 1];
            List<WAMessage__c> l1 = new List<WAMessage__c>();
            for(WAMessage__c wamsgone: wamsglist){
                wamsgone.Read_Recipient__c = current_status;
                l1.add(wamsgone);
            }
            update l1;
        } 
    }
}