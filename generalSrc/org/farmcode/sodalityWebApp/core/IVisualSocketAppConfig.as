package org.farmcode.sodalityWebApp.core
{
	import org.farmcode.sodalityLibrary.core.IStateAppConfig;

	public interface IVisualSocketAppConfig extends IStateAppConfig
	{
		function get rootDataPath():String;
		function get rootDataMappers():Array;
		function get data():Array;
	}
}