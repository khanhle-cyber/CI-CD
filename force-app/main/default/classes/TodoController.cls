public with sharing class TodoController {
    /**
     * Returns Todo__c records exposing Id, Name, Description__c, and Completed__c.
     * Ordered by CreatedDate as requested.
     */
    @AuraEnabled(cacheable=true)
    public static List<Todo__c> getTodos() {
        // CRUD and FLS checks
        if (!Schema.sObjectType.Todo__c.isAccessible()) {
            throw new AuraHandledException('You do not have access to view Todo records.');
        }
        // FLS for fields to be returned
        if (!Todo__c.Name.getDescribe().isAccessible()
            || !Todo__c.Description__c.getDescribe().isAccessible()
            || !Todo__c.Completed__c.getDescribe().isAccessible()) {
            throw new AuraHandledException('You do not have field level access to view required fields.');
        }

        return [
            SELECT Id, Name, Description__c, Completed__c
            FROM Todo__c
            ORDER BY CreatedDate ASC
        ];
    }

    /**
     * Updates ONLY Completed__c for a given Todo__c record and returns the updated record.
     */
    @AuraEnabled
    public static Todo__c setCompleted(Id todoId, Boolean isCompleted) {
        if (todoId == null) {
            throw new AuraHandledException('Todo Id is required.');
        }
        if (!Schema.sObjectType.Todo__c.isUpdateable()) {
            throw new AuraHandledException('You do not have permission to update Todo records.');
        }
        // FLS for the updatable field
        if (!Todo__c.Completed__c.getDescribe().isUpdateable()) {
            throw new AuraHandledException('You do not have permission to update Completed.');
        }

        // Lock the row to prevent races when multiple users toggle
        Todo__c existing = [
            SELECT Id, Completed__c
            FROM Todo__c
            WHERE Id = :todoId
            FOR UPDATE
        ];

        existing.Completed__c = isCompleted;
        update existing;

        // Return only safe fields (including Description__c for display)
        return [
            SELECT Id, Name, Description__c, Completed__c
            FROM Todo__c
            WHERE Id = :existing.Id
            LIMIT 1
        ];
    }
}
