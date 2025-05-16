trigger contentdocumentlinktrigger on ContentVersion (after insert) {
    List<ContentDistribution> cdlist = new List<ContentDistribution>();
    for(ContentVersion cv: Trigger.new){
        if(trigger.isInsert){
            //ContentVersion file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =:cv.Id];
            ContentDistribution cd1 = new ContentDistribution();
            cd1.Name = cv.Title;
            cd1.ContentVersionId = cv.id;
            cd1.PreferencesAllowViewInBrowser= true;
            cd1.PreferencesLinkLatestVersion=true;
            cd1.PreferencesNotifyOnVisit=false;
            cd1.PreferencesPasswordRequired=false;
            cd1.PreferencesAllowOriginalDownload= true;
            cdlist.add(cd1);
        }
        
    }
    insert cdlist;
}