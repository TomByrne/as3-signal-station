package org.farmcode.sodalityLibrary.core
{
	public interface IStateAppConfig extends IAppConfig
	{
		function get defaultAppStatePath():String;
		function get appStates():Array;
	}
}