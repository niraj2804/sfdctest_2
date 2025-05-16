public class WhatsAppController {
    public static String endpointurl = 'https://graph.facebook.com/v14.0/102180689300503/messages';
    public static String apiToken = 'EAAb39CuxMzkBANU2FZAKbYWqIexcjsARVW1f1gyVPkcgAyyjav6kmgBiUI5mKVfQXab9MXtd5mkqNIYA9kRWUZC4NigaOfFJZBhI4LhPoqwy0qvuAyjdOQJCwGyLcfbdZAl2doZC8UxY7LKNP81ox4mZCz1rqUwYVNvAFIxrKzthuHZCYVHZAcTh';
   
    //for sending single text message.
    @AuraEnabled
    public static Boolean sendTemplateMessage(String contactId,String textarea1,String num1){
        String s2 = textarea1;
        if (textarea1.contains('\"') == True){
            textarea1 = textarea1.replace('"','\\"');
            System.debug('in if textarea1: '+textarea1);
        }
        else if(textarea1.contains('\n') == True){
            textarea1 = textarea1.replace('\n','\\n');
            System.debug('in else if textarea1: '+textarea1);
        }
        System.debug('textarea1: '+textarea1);
        //List<WAMessage__c> msgobj = new List<WAMessage__c>();
        //Contact contactDetail  = [SELECT Id,Phone FROM Contact WHERE Id=: contactId];
        String WANumber = '91' + num1;
        if(!WANumber.isNumeric() || WANumber.length()!=12){
            return false;
        }
        System.debug('whatsappnumber: '+WANumber);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointurl);
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        
        //String body = '{"messaging_product": "whatsapp", "to": "'+WANumber+'", "type": "template", "template": { "name": "hello_world", "language": { "code": "en_US" } } }';
        String body = '{"messaging_product": "whatsapp", "to": "'+WANumber+'", "type": "text", "text": {"body":"'+textarea1+'"}, "recipient_type":"individual"}';
        req.setBody(body);
        
        //String apiToken='EAAuPuwLxTigBANqjGOAZATj5Yp7M388c9ZADNyQDUd8nJRvuntr5ksQu4DJVwZBwBRIhuPjJsW9d9zkLG9IJvB7QWffzzLNjnyVQTZAJ7gaJUOLZC1vHVeM9UW9jrlkEJGFDWqA5lKjDIEXZBEeUw847jwZBYaxWRhEVwDhmJf1TVZCBjpcZBYDv6';
        //String apiToken= 'EAAb39CuxMzkBANU2FZAKbYWqIexcjsARVW1f1gyVPkcgAyyjav6kmgBiUI5mKVfQXab9MXtd5mkqNIYA9kRWUZC4NigaOfFJZBhI4LhPoqwy0qvuAyjdOQJCwGyLcfbdZAl2doZC8UxY7LKNP81ox4mZCz1rqUwYVNvAFIxrKzthuHZCYVHZAcTh';
        
        req.setHeader('Authorization','Bearer '+apiToken);
        
        HttpResponse res = http.send(req);
        
        System.debug('response body: '+res.getBody());
        String WAMid = WhatsAppController.fetchwamsgid(res.getBody());
        System.debug('response status code: '+res.getStatusCode());
        
        if(res.getStatusCode() == 200){
            WAMessage__c wamsg = new WAMessage__c(Contact__c=contactId,Message__c=s2,Type__c='Outgoing',Phone_Number__c=num1,WAMid__c=WAMid);
            insert wamsg;
            return true;
        }
        return false;
        
    }
    @AuraEnabled(cacheable=true)
    //for fetching messages.
    public static List<WAMessage__c> fetchMessages(String contactId,String num1) {
        try{
            List<WAMessage__c> msgobj = [SELECT Id,Message__c,Owner.Alias,Contact__r.Name,isIncoming__c, CreatedDate FROM WAMessage__c WHERE Contact__c =:contactId  AND Phone_Number__c =:num1  ORDER BY Name DESC LIMIT 6];
            List<WAMessage__c> test1= new List<WAMessage__c>();
            for(Integer i=msgobj.size()-1;i>=0;i--)
            {
                test1.add(msgobj[i]);
                System.debug('Contact : ' + msgobj.get(i).Contact__r.Name);
            }
            System.debug(test1);
            return test1;
            
        }
        catch(Exception e){
            System.debug('error in fetchMessage '+e);
            return null; 
        }
        
        //List<WAMessage__c> msgobj = [SELECT Id,Message__c,Owner.Alias,Contact__r.Name,isIncoming__c, CreatedDate FROM WAMessage__c WHERE Contact__c =:contactId OR (Contact__r.Phone =:num1 OR Contact__r.MobilePhone=:num1 OR Contact__r.HomePhone=:num1 OR Contact__r.OtherPhone=:num1 OR Contact__r.AssistantPhone=:num1) ORDER BY Name DESC LIMIT 6];
        
    }
    @AuraEnabled(cacheable=true)
    //return wamsgid
    public static String fetchwamsgid(String jsonstring){
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonstring);
        List<Object> msglst = (List<Object>)params.get('messages');
        Map<String, Object> msgdata = (Map<String, Object>) msglst[0];
        String wamsgid = (String) msgdata.get('id');
        return wamsgid;
    }
    //for sending file
    @AuraEnabled(cacheable=true)
    public static Boolean sendsinglefile(String contentdocid,String contactId, String fileurl, String Name, String num1) {
        String body;
        List<String> imgformats = new List<String>{'jpg', 'jpeg', 'png'};
            //List<String> docformats = new List<String> {'pdf'};
        //Contact contactDetail  = [SELECT Id,Phone FROM Contact WHERE Id=:contactId];
        String WANumber = '91' + num1;
        if(!WANumber.isNumeric() || WANumber.length()!=12){
            return false;
        }
        System.debug('whatsappnumber: '+WANumber);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointurl);
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        List<ContentDocument> ftypelist = [SELECT Id,FileExtension FROM ContentDocument WHERE Id =:contentdocid LIMIT 1];
        String filetype1 = ftypelist.get(0).FileExtension;
        
        if(imgformats.contains(filetype1) == True){
            body = '{"messaging_product": "whatsapp", "to": "'+WANumber+'", "type": "image", "image": {"link":"'+fileurl+'"},"recipient_type":"individual"}';
            
        }
        else {
            body = '{"messaging_product": "whatsapp", "to": "'+WANumber+'", "type": "document", "document": {"caption":"'+Name+'" , "link":"'+fileurl+'"},"recipient_type":"individual"}';
        }
        
        req.setBody(body);
        req.setHeader('Authorization','Bearer '+apiToken);
        
        HttpResponse res = http.send(req);
        
        System.debug('response body: '+res.getBody());
        String WAMid = WhatsAppController.fetchwamsgid(res.getBody());
        System.debug('response status code: '+res.getStatusCode());
        if(res.getStatusCode() == 200){
            WAMessage__c wamsg = new WAMessage__c(Contact__c=contactId,Message__c='file : '+Name,Type__c='Outgoing', Phone_Number__c=num1,WAMid__c=WAMid);
            System.debug('file send successfully.');
            insert wamsg;
            System.debug('WAMessage Id : '+ wamsg.Id);
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentdocid;
            cdl.LinkedEntityId = wamsg.Id;
            cdl.ShareType = 'V';
            insert cdl;
            System.debug('file successfully stored in related files.');
            return true;
            
        }
        return false;
        
    }
    
}