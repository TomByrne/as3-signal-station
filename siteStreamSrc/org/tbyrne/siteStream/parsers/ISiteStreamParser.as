package org.tbyrne.siteStream.parsers
{
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.siteStream.SiteStreamNode;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	[Event(name="classFailure",type="org.tbyrne.siteStream.events.SiteStreamErrorEvent")]
	[Event(name="dataFailure",type="org.tbyrne.siteStream.events.SiteStreamErrorEvent")]
	public interface ISiteStreamParser extends IEventDispatcher
	{
		function set parentParser(value:ISiteStreamParser):void;
		
		// data loading phase
		function isDataLoaded(propInfo:IPropertyInfo):Boolean;
		function loadData(propInfo:IPropertyInfo):IPendingResult;
		
		// class loading phase
		function isClassLoaded(propInfo:IPropertyInfo):Boolean;
		function loadClass(propInfo:IPropertyInfo):IPendingResult;
		
		// parsing phase
		function initPropertyInfo(propertyInfo:IPropertyInfo):void;
		function createNewPropertyInfo():IPropertyInfo;
		function getNodeReference(propertyInfo:IPropertyInfo):String;
		function createObject(propertyInfo:IPropertyInfo):IPendingResult;
		
		// child assessment phase
		function getChildProperties(propertyInfo:IPropertyInfo):Array;
		function parseLazily(propertyInfo:IPropertyInfo):Boolean;
		function compareChildIds(id1:String,id2:String):Boolean;
		
		// commitment phase
		function commitValue(propertyInfo:IPropertyInfo, node:SiteStreamNode):void;
		
		// release phase
		/**
		 * @return A boolean determining whether the node's data was successfully released.
		 */
		function releaseData(propInfo:IPropertyInfo):Boolean
		function releaseClass(propInfo:IPropertyInfo):void
	}
}