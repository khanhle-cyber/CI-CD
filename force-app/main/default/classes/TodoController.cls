public with sharing class TodoController {
  @TestVisible
  private static TodoSecurityService securityService = new TodoSecurityService();

  @AuraEnabled(cacheable=true)
  public static List<Todo__c> getTodos() {
    if (!securityService.canAccessTodo()) {
      throw new AuraHandledException(
        'You do not have access to view Todo records.'
      );
    }

    if (!securityService.canAccessTodoFields()) {
      throw new AuraHandledException(
        'You do not have field level access to view required fields.'
      );
    }

    return [
      SELECT Id, Name, Description__c, Completed__c
      FROM Todo__c
      ORDER BY CreatedDate ASC
    ];
  }

  @AuraEnabled
  public static Todo__c setCompleted(Id todoId, Boolean isCompleted) {
    if (todoId == null) {
      throw new AuraHandledException('Todo Id is required.');
    }

    if (!securityService.canUpdateTodo()) {
      throw new AuraHandledException(
        'You do not have permission to update Todo records.'
      );
    }

    if (!securityService.canUpdateCompletedField()) {
      throw new AuraHandledException(
        'You do not have permission to update Completed.'
      );
    }

    Todo__c existing = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Id = :todoId
      FOR UPDATE
    ];

    existing.Completed__c = isCompleted;
    update existing;

    return [
      SELECT Id, Name, Description__c, Completed__c
      FROM Todo__c
      WHERE Id = :existing.Id
      LIMIT 1
    ];
  }
}
