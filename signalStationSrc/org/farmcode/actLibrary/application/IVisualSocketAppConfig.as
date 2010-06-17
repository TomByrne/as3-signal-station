package org.farmcode.actLibrary.application
{
	public interface IVisualSocketAppConfig extends IStateAppConfig
	{
		function get rootDataPath():String;
		function get rootDataMappers():Array;
		function get data():Array;
	}
}