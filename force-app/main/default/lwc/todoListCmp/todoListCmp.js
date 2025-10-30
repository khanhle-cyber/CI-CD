import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


import getTodos from '@salesforce/apex/TodoController.getTodos';
import setCompleted from '@salesforce/apex/TodoController.setCompleted';

export default class TodoListCmp extends LightningElement {
    @track isUpdating = false;
    
    wiredTodosResult;
    
    @track todosData = [];
    @track todosError;

    @wire(getTodos)
    wiredTodos(result) {
        this.wiredTodosResult = result;
        if (result.data) {
            // Create a mutable copy of the data
            this.todosData = JSON.parse(JSON.stringify(result.data));
            this.todosError = undefined;
        } else if (result.error) {
            this.todosError = result.error;
            this.todosData = [];
        }
    }

 // Handle checkbox toggle
    async handleToggle(event) {
        const id = event.target.dataset.id;
        const newValue = event.target.checked;

        // Save snapshot for rollback
        const snapshot = JSON.parse(JSON.stringify(this.todosData));

        try {
            // Optimistic UI update
            const idx = this.todosData.findIndex(r => r.Id === id);
            if (idx > -1) {
                this.todosData[idx].Completed__c = newValue;
                // Force reactivity
                this.todosData = [...this.todosData];
            }

            this.isUpdating = true;
            await setCompleted({ todoId: id, isCompleted: newValue });

            // Refresh the wired data
            await refreshApex(this.wiredTodosResult);

        } catch (e) {
            // Rollback UI to previous state if error
            this.todosData = snapshot;
            this.dispatchEvent(new ShowToastEvent({ 
                title: 'Error', 
                message: this._userMessage(e), 
                variant: 'error' 
            }));
        } finally {
            this.isUpdating = false;
        }
    }

    // _cloneData(data) {
    //     return data ? JSON.parse(JSON.stringify(data)) : null;
    // }

    // _restoreSnapshot(snapshot) {
    //     if (snapshot) {
    //         // eslint-disable-next-line @lwc/lwc/no-async-operation
    //         this.todos = { data: snapshot, error: undefined };
    //     }
    // }

    // _applyLocalToggle(id, newValue) {
    //     if (!this.todos || !this.todos.data) return;
    //     const idx = this.todos.data.findIndex(r => r.Id === id);
    //     if (idx > -1) {
    //         this.todos.data[idx].Completed__c = newValue;
    //     }
    // }

    _userMessage(e) {
            let msg = 'An unexpected error occurred.';
            if (e && e.body && e.body.message) {
                msg = e.body.message;
            } else if (e && e.message) {
                msg = e.message;
            }
            return msg;
        }
}