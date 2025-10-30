@isTest
private class TodoControllerTest {
  @TestSetup
  static void setupTestData() {
    // Create test Todo records
    List<Todo__c> testTodos = new List<Todo__c>{
      new Todo__c(
        Name = 'Test Todo 1',
        Description__c = 'First test todo',
        Completed__c = false
      ),
      new Todo__c(
        Name = 'Test Todo 2',
        Description__c = 'Second test todo',
        Completed__c = true
      ),
      new Todo__c(
        Name = 'Test Todo 3',
        Description__c = 'Third test todo',
        Completed__c = false
      )
    };
    insert testTodos;
  }

  @isTest
  static void testGetTodos_Success() {
    // Test successful retrieval of todos
    Test.startTest();
    List<Todo__c> todos = TodoController.getTodos();
    Test.stopTest();

    // Verify results
    System.assertEquals(3, todos.size(), 'Should return 3 todos');

    // Verify ordering by CreatedDate (ascending)
    System.assertEquals(
      'Test Todo 1',
      todos[0].Name,
      'First todo should be Test Todo 1'
    );
    System.assertEquals(
      'Test Todo 2',
      todos[1].Name,
      'Second todo should be Test Todo 2'
    );
    System.assertEquals(
      'Test Todo 3',
      todos[2].Name,
      'Third todo should be Test Todo 3'
    );

    // Verify all required fields are populated
    for (Todo__c todo : todos) {
      System.assertNotEquals(null, todo.Id, 'Id should not be null');
      System.assertNotEquals(null, todo.Name, 'Name should not be null');
      System.assert(
        todo.Description__c != null,
        'Description__c should not be null'
      );
      System.assert(
        todo.Completed__c != null,
        'Completed__c should not be null'
      );
    }
  }

  @isTest
  static void testGetTodos_NoRecords() {
    // Delete all test data
    delete [SELECT Id FROM Todo__c];

    Test.startTest();
    List<Todo__c> todos = TodoController.getTodos();
    Test.stopTest();

    // Verify empty list is returned
    System.assertEquals(
      0,
      todos.size(),
      'Should return empty list when no todos exist'
    );
  }

  // @isTest
  // static void testGetTodos_NoObjectAccess() {
  //     // Create a user with minimal permissions
  //     Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  //     User testUser = new User(
  //         Alias = 'tuser',
  //         Email = 'testuser@example.com',
  //         EmailEncodingKey = 'UTF-8',
  //         LastName = 'Testing',
  //         LanguageLocaleKey = 'en_US',
  //         LocaleSidKey = 'en_US',
  //         ProfileId = p.Id,
  //         TimeZoneSidKey = 'America/Los_Angeles',
  //         UserName = 'testuser' + System.currentTimeMillis() + '@example.com'
  //     );
  //     insert testUser;

  //     Test.startTest();
  //     System.runAs(testUser) {
  //         try {
  //             TodoController.getTodos();
  //             System.assert(false, 'Should have thrown an exception for no object access');
  //         } catch (AuraHandledException e) {
  //             System.assert(e.getMessage().contains('access'),
  //                          'Should throw access-related error message');
  //         }
  //     }
  //     Test.stopTest();
  // }

  @isTest
  static void testSetCompleted_MarkAsCompleted() {
    // Get a todo that is not completed
    Todo__c todo = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Name = 'Test Todo 1'
      LIMIT 1
    ];
    System.assertEquals(
      false,
      todo.Completed__c,
      'Initial state should be not completed'
    );

    Test.startTest();
    Todo__c updatedTodo = TodoController.setCompleted(todo.Id, true);
    Test.stopTest();

    // Verify the todo was marked as completed
    System.assertEquals(
      true,
      updatedTodo.Completed__c,
      'Todo should be marked as completed'
    );
    System.assertEquals(todo.Id, updatedTodo.Id, 'Should return the same todo');

    // Verify all fields are returned
    System.assertNotEquals(null, updatedTodo.Name, 'Name should be returned');
    System.assertNotEquals(
      null,
      updatedTodo.Description__c,
      'Description__c should be returned'
    );

    // Verify the change persisted in the database
    Todo__c verifyTodo = [SELECT Completed__c FROM Todo__c WHERE Id = :todo.Id];
    System.assertEquals(
      true,
      verifyTodo.Completed__c,
      'Completed status should persist in database'
    );
  }

  @isTest
  static void testSetCompleted_MarkAsIncomplete() {
    // Get a todo that is already completed
    Todo__c todo = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Name = 'Test Todo 2'
      LIMIT 1
    ];
    System.assertEquals(
      true,
      todo.Completed__c,
      'Initial state should be completed'
    );

    Test.startTest();
    Todo__c updatedTodo = TodoController.setCompleted(todo.Id, false);
    Test.stopTest();

    // Verify the todo was marked as incomplete
    System.assertEquals(
      false,
      updatedTodo.Completed__c,
      'Todo should be marked as incomplete'
    );
    System.assertEquals(todo.Id, updatedTodo.Id, 'Should return the same todo');

    // Verify the change persisted in the database
    Todo__c verifyTodo = [SELECT Completed__c FROM Todo__c WHERE Id = :todo.Id];
    System.assertEquals(
      false,
      verifyTodo.Completed__c,
      'Completed status should persist in database'
    );
  }

  @isTest
  static void testSetCompleted_NullId() {
    // Test with null ID
    Boolean exceptionThrown = false;

    Test.startTest();
    try {
      TodoController.setCompleted(null, true);
    } catch (AuraHandledException e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      exceptionThrown,
      'Should have thrown AuraHandledException for null ID'
    );
  }

  @isTest
  static void testSetCompleted_InvalidId() {
    // Get a real Todo record and then delete it to get a valid but non-existent ID
    Todo__c todo = [SELECT Id FROM Todo__c WHERE Name = 'Test Todo 1' LIMIT 1];
    Id deletedId = todo.Id;
    delete todo;

    Test.startTest();
    try {
      TodoController.setCompleted(deletedId, true);
      System.assert(
        false,
        'Should have thrown an exception for non-existent record'
      );
    } catch (QueryException e) {
      // The FOR UPDATE query will throw a QueryException when no rows are found
      System.assert(
        e.getMessage().contains('List has no rows'),
        'Should throw QueryException for non-existent record'
      );
    } catch (Exception e) {
      System.assert(
        false,
        'Unexpected exception type: ' +
          e.getTypeName() +
          ', Message: ' +
          e.getMessage()
      );
    }
    Test.stopTest();
  }

  // @isTest
  // static void testSetCompleted_NoUpdateAccess() {
  //     // Create a user with minimal permissions
  //     Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  //     User testUser = new User(
  //         Alias = 'tuser2',
  //         Email = 'testuser2@example.com',
  //         EmailEncodingKey = 'UTF-8',
  //         LastName = 'Testing2',
  //         LanguageLocaleKey = 'en_US',
  //         LocaleSidKey = 'en_US',
  //         ProfileId = p.Id,
  //         TimeZoneSidKey = 'America/Los_Angeles',
  //         UserName = 'testuser2' + System.currentTimeMillis() + '@example.com'
  //     );
  //     insert testUser;

  //     Todo__c todo = [SELECT Id FROM Todo__c WHERE Name = 'Test Todo 1' LIMIT 1];

  //     Test.startTest();
  //     System.runAs(testUser) {
  //         try {
  //             TodoController.setCompleted(todo.Id, true);
  //             System.assert(false, 'Should have thrown an exception for no update access');
  //         } catch (AuraHandledException e) {
  //             System.assert(e.getMessage().contains('permission'),
  //                          'Should throw permission-related error message');
  //         }
  //     }
  //     Test.stopTest();
  // }

  @isTest
  static void testSetCompleted_ConcurrentUpdate() {
    // This tests the FOR UPDATE lock behavior
    Todo__c todo = [SELECT Id FROM Todo__c WHERE Name = 'Test Todo 1' LIMIT 1];

    Test.startTest();
    // First update
    Todo__c updated1 = TodoController.setCompleted(todo.Id, true);
    System.assertEquals(
      true,
      updated1.Completed__c,
      'First update should succeed'
    );

    // Second update on same record (simulating concurrent access)
    Todo__c updated2 = TodoController.setCompleted(todo.Id, false);
    System.assertEquals(
      false,
      updated2.Completed__c,
      'Second update should succeed'
    );
    Test.stopTest();

    // Verify final state
    Todo__c finalTodo = [SELECT Completed__c FROM Todo__c WHERE Id = :todo.Id];
    System.assertEquals(
      false,
      finalTodo.Completed__c,
      'Final state should reflect last update'
    );
  }

  @isTest
  static void testSetCompleted_ToggleSameValue() {
    // Test setting completed to the same value it already has
    Todo__c todo = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Name = 'Test Todo 2'
      LIMIT 1
    ];
    Boolean originalValue = todo.Completed__c;

    Test.startTest();
    Todo__c updatedTodo = TodoController.setCompleted(todo.Id, originalValue);
    Test.stopTest();

    // Should still work without error
    System.assertEquals(
      originalValue,
      updatedTodo.Completed__c,
      'Value should remain the same'
    );
  }
}
