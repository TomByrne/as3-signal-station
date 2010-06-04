package org.farmcode.acting.actTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.IScopeDisplayObject;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	/**
	 * handler(endHandler:Function, parentExecution:UniversalActExecution, ... params);
	 */
	public interface IUniversalAct extends IAsynchronousAct, IScopeDisplayObject
	{
		
	}
}