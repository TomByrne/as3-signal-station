package org.farmcode.sodalityWebApp.core
{
	import org.farmcode.actLibrary.application.IStateAppConfig;

	public interface IVisualSocketAppConfig extends IStateAppConfig
	{
		function get rootDataPath():String;
		function get rootDataMappers():Array;
		function get data():Array;
	}
}