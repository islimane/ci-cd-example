/**
 * @description An opinionated trigger handler framework.
 * Originally by Kevin O'Hara github.com/kevinohara80/sfdc-trigger-framework
 * Improved with bypass Custom Setting add-on
 * @group Shared Code
 * @see AccountTriggerHandler, PlatformEventRecipesTriggerHandler
 * @author       : development@nubika.com | 24-01-2023
 * @version      : 1.0.0
 * @date         : 24-01-2023
 */

@SuppressWarnings('PMD.CyclomaticComplexity')
public virtual class TriggerHandler {
	// static map of handlername, times run() was invoked
	private static Map<String, LoopCount> mLoopCountMapByHandlerName;
	private static Set<String> sBypassedHandlers;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private TriggerContext context;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private Boolean isTriggerExecuting;

	// static initialization
	static {
		mLoopCountMapByHandlerName = new Map<String, LoopCount>();
		sBypassedHandlers = new Set<String>();
	}

    /**
    * @description Trigger Handler constructor
    * @author development@nubika.com | 24-01-2023
    **/
	public TriggerHandler() {
		this.setTriggerContext();
	}

	/***************************************
	 * public instance methods
	 ***************************************/

	/**
    * @description main method that will be called during execution
    * @author development@nubika.com | 24-01-2023
    **/
	public void run() {

		if(!validateRun()) {
			return;
		}

		addToLoopCount();

		// dispatch to the correct handler method
		switch on this.context {
			when BEFORE_INSERT {
				this.beforeInsert();
			}
			when BEFORE_UPDATE {
				this.beforeUpdate();
			}
			when BEFORE_DELETE {
				this.beforeDelete();
			}
			when AFTER_INSERT {
				this.afterInsert();
			}
			when AFTER_UPDATE {
				this.afterUpdate();
			}
			when AFTER_DELETE {
				this.afterDelete();
			}
			when AFTER_UNDELETE {
				this.afterUndelete();
			}
		}
	}

	/**
    * @description set max loop count
    * @author development@nubika.com | 24-01-2023
	* @param max maximum loop count
    **/
	public void setMaxLoopCount(Integer max) {
		String handlerName = getHandlerName();
		if(!TriggerHandler.mLoopCountMapByHandlerName.containsKey(handlerName)) {
			TriggerHandler.mLoopCountMapByHandlerName.put(handlerName, new LoopCount(max));
		} else {
			TriggerHandler.mLoopCountMapByHandlerName.get(handlerName).setMax(max);
		}
	}

	/**
    * @description clear max loop count
    * @author development@nubika.com | 24-01-2023
    **/
	public void clearMaxLoopCount() {
		this.setMaxLoopCount(-1);
	}

	/***************************************
	 * public static methods
	 ***************************************/

	/**
    * @description add bypass for a handler
    * @author development@nubika.com | 24-01-2023
	* @param handlerName handler name
    **/
	public static void bypass(String handlerName) {
		TriggerHandler.sBypassedHandlers.add(handlerName);
	}

	/**
    * @description add bypass for a handler
    * @author development@nubika.com | 24-01-2023
	* @param handlerName handler name
    **/
	public static void clearBypass(String handlerName) {
		TriggerHandler.sBypassedHandlers.remove(handlerName);
	}

	/**
    * @description check if a handler is bypassed
    * @author development@nubika.com | 24-01-2023
	* @param handlerName handler name
	* @return true if bypassed or false if not bypassed
    **/
	public static Boolean isBypassed(String handlerName) {
		return TriggerHandler.sBypassedHandlers.contains(handlerName);
	}

	/**
    * @description clear all bypass
    * @author development@nubika.com | 24-01-2023
    **/
	public static void clearAllBypasses() {
		TriggerHandler.sBypassedHandlers.clear();
	}

	/***************************************
	 * private instancemethods
	 ***************************************/

	/**
    * @description set trigger context
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(null, false);
	}

    @SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
	@TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if(!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
			(ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
			(ctx != null && ctx == 'before update')){
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
			(ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
			(ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
			(ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
			(ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
			(ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	// increment the loop count
	@TestVisible
	private void addToLoopCount() {
		String handlerName = getHandlerName();
		if(TriggerHandler.mLoopCountMapByHandlerName.containsKey(handlerName)) {
			Boolean exceeded = TriggerHandler.mLoopCountMapByHandlerName.get(handlerName).increment();
			if(exceeded) {
				Integer max = TriggerHandler.mLoopCountMapByHandlerName.get(handlerName).max;
				throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
			}
		}
	}


	// make sure this trigger should continue to run
    @SuppressWarnings('PMD.CyclomaticComplexity')
	@TestVisible
	private Boolean validateRun() {
		Boolean triggerCanRun = true;
		ByPassConfig__c byPassConfig = ByPassConfig__c.getInstance();
		if (!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		} else if (TriggerHandler.sBypassedHandlers.contains(getHandlerName())) {
			triggerCanRun = false;
		} else if (byPassConfig != null) {
			if (byPassConfig.DisableTriggers__c) {
				triggerCanRun = false;
			} else if (String.isNotBlank(byPassConfig.TriggerObjects__c)) {
				String currentSObjectType = null;
				Set<String> sObjectsTypeToByPassList = new Set<String>(byPassConfig.TriggerObjects__c.split(','));
				currentSObjectType = (Trigger.old != null)? Trigger.old.getSObjectType().getDescribe().getName() : currentSObjectType;
				currentSObjectType = (Trigger.new != null)? Trigger.new.getSObjectType().getDescribe().getName() : currentSObjectType;
				triggerCanRun = !sObjectsTypeToByPassList.contains(currentSObjectType);
			}
		}
		return triggerCanRun;
	}

	@TestVisible
	private String getHandlerName() {
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}

	/***************************************
	 * context methods
	 ***************************************/

	// context-specific methods for override


	/**
    * @description method to be executed before insert
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void beforeInsert(){}

	/**
    * @description method to be executed before update
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void beforeUpdate(){}

	/**
    * @description method to be executed before delete
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void beforeDelete(){}

	/**
    * @description method to be executed after insert
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void afterInsert(){}

	/**
    * @description method to be executed after update
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void afterUpdate(){}

	/**
    * @description method to be executed after delete
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void afterDelete(){}

	/**
    * @description method to be executed after delete
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
	protected virtual void afterUndelete(){}

	/***************************************
	 * inner classes
	 ***************************************/

	/**
    * @description inner class for managing the loop count per handler
    * @author development@nubika.com | 24-01-2023
    **/
	@TestVisible
	private class LoopCount {
		private Integer max;
		private Integer count;

		/**
		* @description default constructor
		* @author development@nubika.com | 24-01-2023
		**/
		public LoopCount() {
			this.max = 5;
			this.count = 0;
		}

		/**
		* @description constructor with maximum
		* @author development@nubika.com | 24-01-2023
		* @param max maximum loop count
		**/
		public LoopCount(Integer max) {
			this.max = max;
			this.count = 0;
		}

		/**
		* @description increment loop count
		* @author development@nubika.com | 24-01-2023
		* @return if count was exceeded
		**/
		public Boolean increment() {
			this.count++;
			return this.exceeded();
		}

		/**
		* @description get if count was exceeded
		* @author development@nubika.com | 24-01-2023
		* @return if count was exceeded
		**/
		public Boolean exceeded() {
			return this.max >= 0 && this.count > this.max;
		}

		/**
		* @description get maximum loop count
		* @author development@nubika.com | 24-01-2023
		* @return maximum loop count
		**/
		public Integer getMax() {
			return this.max;
		}

		/**
		* @description get loop count
		* @author development@nubika.com | 24-01-2023
		* @return loop count
		**/
		public Integer getCount() {
			return this.count;
		}

		/**
		* @description set loop count maximum
		* @author development@nubika.com | 24-01-2023
		* @param max maximum loop count
		**/
		public void setMax(Integer max) {
			this.max = max;
		}
	}

	// possible trigger contexts
	@TestVisible
	private enum TriggerContext {
		BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
		AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
		AFTER_UNDELETE
	}

	/**
	* @description Trigger Handler Exception
	* @author development@nubika.com | 24-01-2023
	**/
	public class TriggerHandlerException extends Exception {}
}