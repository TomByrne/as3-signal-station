package org.tbyrne.siteStream.parsers
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.siteStream.SiteStreamNode;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	public interface ISiteStreamParser
	{
		
		/**
		 * handler(from:ISiteStreamParser)
		 */
		function get dataLoadFailure():IAct;
		/**
		 * handler(from:ISiteStreamParser)
		 */
		function get classLoadFailure():IAct;
		
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