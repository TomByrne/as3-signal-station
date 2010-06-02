package org.farmcode.siteStream.dataLoader
{
	import flash.events.IEventDispatcher;
	
	import org.farmcode.core.IPendingResult;
	
	[Event(name="dataFailure",type="org.farmcode.siteStream.events.SiteStreamErrorEvent")]
	public interface IDataLoader extends IEventDispatcher
	{
		function isDataLoaded(dataInfo:IDataInfo):Boolean;
		function loadData(dataInfo:IDataInfo):IPendingResult;
		function releaseData(dataInfo:IDataInfo):void;
	}
}