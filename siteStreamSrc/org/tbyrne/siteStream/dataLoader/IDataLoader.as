package org.tbyrne.siteStream.dataLoader
{
	import flash.events.IEventDispatcher;
	
	import org.tbyrne.core.IPendingResult;
	
	[Event(name="dataFailure",type="org.tbyrne.siteStream.events.SiteStreamErrorEvent")]
	public interface IDataLoader extends IEventDispatcher
	{
		function isDataLoaded(dataInfo:IDataInfo):Boolean;
		function loadData(dataInfo:IDataInfo):IPendingResult;
		function releaseData(dataInfo:IDataInfo):void;
	}
}