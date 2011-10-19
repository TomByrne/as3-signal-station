package org.tbyrne.siteStream.dataLoader
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.core.IPendingResult;
	
	public interface IDataLoader
	{
		/**
		 * handler(from:IDataLoader)
		 */
		function get dataLoadFailure():IAct;
		
		function isDataLoaded(dataInfo:IDataInfo):Boolean;
		function loadData(dataInfo:IDataInfo):IPendingResult;
		function releaseData(dataInfo:IDataInfo):void;
	}
}