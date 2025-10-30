public virtual class TodoSecurityService {
  public virtual Boolean canAccessTodo() {
    return Schema.sObjectType.Todo__c.isAccessible();
  }

  public virtual Boolean canAccessTodoFields() {
    return Todo__c.Name.getDescribe().isAccessible() &&
      Todo__c.Description__c.getDescribe().isAccessible() &&
      Todo__c.Completed__c.getDescribe().isAccessible();
  }

  public virtual Boolean canUpdateTodo() {
    return Schema.sObjectType.Todo__c.isUpdateable();
  }

  public virtual Boolean canUpdateCompletedField() {
    return Todo__c.Completed__c.getDescribe().isUpdateable();
  }
}
