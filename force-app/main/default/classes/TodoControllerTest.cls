@IsTest // FIX: Required annotation for a class containing test methods. (Resolves errors 33:17, 72:17, 116:17, 140:17, 195:17, 239:17, 271:17)
private class TodoControllerTest {
  // --- HELPER METHOD TO SAFELY CREATE A TEST USER (Prevents REQUIRED_FIELD_MISSING DML errors) ---
  private static User getStandardUser() {
    // 1. Get the Profile ID for the new user
    Profile standardProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];

    // 2. Generate unique values for mandatory fields
    String uniqueTime = String.valueOf(System.currentTimeMillis());
    String uniqueUsername = 'testuser' + uniqueTime + '@testorg.com';
    String uniqueAlias = 'susr' + uniqueTime.right(4);

    // 3. Create the user object with all required fields populated
    User restrictedUser = new User(
      ProfileId = standardProfile.Id,
      LastName = 'TestUser' + uniqueTime,
      Email = 'testuser' + uniqueTime + '@test.com',
      Username = uniqueUsername,
      Alias = uniqueAlias,
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    // 4. Insert the user
    insert restrictedUser;
    return restrictedUser;
  }
  // --- END HELPER METHOD ---

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

  // Test for read access and FLS failure
  @IsTest
  static void getTodos_NoReadAccess_ThrowsException() {
    // Create a user for the runAs context
    User restrictedUser = getStandardUser();

    System.runAs(restrictedUser) {
      Test.startTest();
      try {
        TodoController.getTodos();
        // If this line is reached, the exception was NOT thrown (FAILURE)
        System.assert(
          false,
          'Expected AuraHandledException was not thrown for missing read/FLS.'
        );
      } catch (AuraHandledException e) {
        // If this line is reached, the exception was thrown (SUCCESS)
        System.assert(
          e.getMessage().contains('access') ||
          e.getMessage().contains('permission'),
          'Exception message should indicate a security/permission issue.'
        );
      }
      Test.stopTest();
    }
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

  // Test for update access and FLS failure
  @IsTest
  static void setCompleted_NoUpdateAccess_ThrowsException() {
    Todo__c todoToUpdate = [
      SELECT Id
      FROM Todo__c
      WHERE Completed__c = FALSE
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];

    // Create a user for the runAs context
    User restrictedUser = getStandardUser();

    System.runAs(restrictedUser) {
      Test.startTest();
      try {
        // Assuming the user lacks object update or Completed__c FLS update permission
        TodoController.setCompleted(todoToUpdate.Id, true);
        // If this line is reached, the exception was NOT thrown (FAILURE)
        System.assert(
          false,
          'Expected AuraHandledException was not thrown for missing update/FLS.'
        );
      } catch (AuraHandledException e) {
        // FIX: Broaden the assertion to catch generic security failures
        System.assert(
          e.getMessage().contains('permission') ||
          e.getMessage().contains('access'),
          'Exception message should indicate a security/permission issue.'
        );
      }
      Test.stopTest();
    }
  }

  // Fixed test for null ID exception
  @IsTest
  static void setCompleted_NullId_ThrowsException() {
    Test.startTest();
    try {
      // Passing a null Id
      TodoController.setCompleted(null, true);
      // This line is hit if the exception was NOT thrown (FAILURE)
      System.assert(
        false,
        'Expected AuraHandledException was not thrown for null Id.'
      );
    } catch (AuraHandledException e) {
      // This line is hit if the expected exception IS thrown (SUCCESS)
      System.assertEquals(
        'Todo Id is required.',
        e.getMessage(),
        'Incorrect exception message for null Id.'
      );
    }
    Test.stopTest();
  }
}
