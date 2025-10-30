public with sharing class TodoController {
  /**
   * Test seam to allow unit tests to simulate FLS/CRUD outcomes without changing real org permissions.
   */
  @TestVisible
  private virtual class Access {
    virtual Boolean canReadTodo() {
      return Schema.sObjectType.Todo__c.isAccessible();
    }
    virtual Boolean canReadFields() {
      return Todo__c.Name.getDescribe().isAccessible() &&
        Todo__c.Description__c.getDescribe().isAccessible() &&
        Todo__c.Completed__c.getDescribe().isAccessible();
    }
    virtual Boolean canUpdateTodo() {
      return Schema.sObjectType.Todo__c.isUpdateable();
    }
    virtual Boolean canUpdateCompleted() {
      return Todo__c.Completed__c.getDescribe().isUpdateable();
    }
  }
  @TestVisible
  static Access access = new Access();

  /**
   * Returns Todo__c records exposing Id, Name, Description__c, and Completed__c.
   * Ordered by CreatedDate as requested.
   */
  @AuraEnabled(cacheable=true)
  public static List<Todo__c> getTodos() {
    // CRUD and FLS checks
    if (!access.canReadTodo()) {
      throw new AuraHandledException(
        'You do not have access to view Todo records.'
      );
    }
    // FLS for fields to be returned
    if (!access.canReadFields()) {
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

  /**
   * Updates ONLY Completed__c for a given Todo__c record and returns the updated record.
   */
  @AuraEnabled
  public static Todo__c setCompleted(Id todoId, Boolean isCompleted) {
    if (todoId == null) {
      throw new AuraHandledException('Todo Id is required.');
    }
    if (!access.canUpdateTodo()) {
      throw new AuraHandledException(
        'You do not have permission to update Todo records.'
      );
    }
    // FLS for the updatable field
    if (!access.canUpdateCompleted()) {
      throw new AuraHandledException(
        'You do not have permission to update Completed.'
      );
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
