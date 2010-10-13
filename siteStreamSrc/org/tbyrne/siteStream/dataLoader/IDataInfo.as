package org.tbyrne.siteStream.dataLoader
{
	public interface IDataInfo
	{
		function set loadedData(value:XML):void;
		function get bestData():XML;
	}
}