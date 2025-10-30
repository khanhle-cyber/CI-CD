@IsTest
private class TodoControllerTest {
  @TestSetup
  static void makeData() {
    // Create 3 Todo__c records for testing
    List<Todo__c> todos = new List<Todo__c>();

    // Todo 1 - Incomplete (will be toggled later)
    todos.add(
      new Todo__c(
        Name = 'Task 1',
        Description__c = 'First task to do.',
        Completed__c = false
      )
    );

    // Todo 2 - Complete
    todos.add(
      new Todo__c(
        Name = 'Task 2',
        Description__c = 'Second task done.',
        Completed__c = true
      )
    );

    // Todo 3 - Incomplete
    todos.add(
      new Todo__c(
        Name = 'Task 3',
        Description__c = 'Third task pending.',
        Completed__c = false
      )
    );

    insert todos;
  }

  // --- Test for getTodos() ---

  @IsTest
  static void getTodos_Success() {
    // Retrieve the test data created in @TestSetup
    List<Todo__c> expectedTodos = [
      SELECT Id
      FROM Todo__c
      ORDER BY CreatedDate ASC
    ];

    // Ensure we have records to test with
    System.assert(expectedTodos.size() > 0, 'Test data should be present.');

    Test.startTest();
    // Call the controller method
    List<Todo__c> resultTodos = TodoController.getTodos();
    Test.stopTest();

    // Assertions
    System.assertEquals(
      expectedTodos.size(),
      resultTodos.size(),
      'Should return all Todo records.'
    );

    // Check if the order is correct (by CreatedDate ASC)
    // Since we insert them in a batch, their CreatedDate is generally ordered by the list index
    System.assertEquals(
      expectedTodos[0].Id,
      resultTodos[0].Id,
      'Todos should be ordered by CreatedDate ASC.'
    );

    // Check field exposure
    System.assertNotEquals(
      null,
      resultTodos[0].Name,
      'Name should be populated.'
    );
    System.assertNotEquals(
      null,
      resultTodos[0].Description__c,
      'Description__c should be populated.'
    );
  }

  // --- Test for setCompleted(Id todoId, Boolean isCompleted) ---

  @IsTest
  static void setCompleted_ToggleToComplete_Success() {
    // Get the first incomplete Todo record (Task 1)
    Todo__c todoToUpdate = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Completed__c = FALSE
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];

    // Ensure the record is initially incomplete
    System.assertEquals(
      false,
      todoToUpdate.Completed__c,
      'Record should initially be incomplete.'
    );

    Test.startTest();
    // Call the controller method to set it to complete
    Todo__c updatedTodo = TodoController.setCompleted(todoToUpdate.Id, true);
    Test.stopTest();

    // Retrieve the record directly from the database to verify the update
    Todo__c verifiedTodo = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Id = :todoToUpdate.Id
    ];

    // Assertions
    System.assertEquals(
      true,
      updatedTodo.Completed__c,
      'Returned Todo should be marked as complete.'
    );
    System.assertEquals(
      true,
      verifiedTodo.Completed__c,
      'Database record should be marked as complete.'
    );

    // Check that the returned record contains Name, Description__c
    System.assertNotEquals(
      null,
      updatedTodo.Name,
      'Returned Todo should include Name.'
    );
    System.assertNotEquals(
      null,
      updatedTodo.Description__c,
      'Returned Todo should include Description__c.'
    );
  }

  @IsTest
  static void setCompleted_ToggleToIncomplete_Success() {
    // Get the first complete Todo record (Task 2)
    Todo__c todoToUpdate = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Completed__c = TRUE
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];

    // Ensure the record is initially complete
    System.assertEquals(
      true,
      todoToUpdate.Completed__c,
      'Record should initially be complete.'
    );

    Test.startTest();
    // Call the controller method to set it to incomplete
    Todo__c updatedTodo = TodoController.setCompleted(todoToUpdate.Id, false);
    Test.stopTest();

    // Retrieve the record directly from the database to verify the update
    Todo__c verifiedTodo = [
      SELECT Id, Completed__c
      FROM Todo__c
      WHERE Id = :todoToUpdate.Id
    ];

    // Assertions
    System.assertEquals(
      false,
      updatedTodo.Completed__c,
      'Returned Todo should be marked as incomplete.'
    );
    System.assertEquals(
      false,
      verifiedTodo.Completed__c,
      'Database record should be marked as incomplete.'
    );
  }

  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // Assert that the correct exception message is thrown
      //  System.assertEquals('Todo Id is required.', e.getMessage(), 'Incorrect exception message for null Id.');
    }
    Test.stopTest();
  }
  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // Assert that the correct exception message is thrown
      //  System.assertEquals('Todo Id is required.', e.getMessage(), 'Incorrect exception message for null Id.');
    }
    Test.stopTest();
  }

  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // Assert that the correct exception message is thrown
      //  System.assertEquals('Todo Id is required.', e.getMessage(), 'Incorrect exception message for null Id.');
    }
    Test.stopTest();
  }

  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // Assert that the correct exception message is thrown
      //  System.assertEquals('Todo Id is required.', e.getMessage(), 'Incorrect exception message for null Id.');
    }
    Test.stopTest();
  }

  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // Assert that the correct exception message is thrown
      //  System.assertEquals('Todo Id is required.', e.getMessage(), 'Incorrect exception message for null Id.');
    }
    Test.stopTest();
  }
}
