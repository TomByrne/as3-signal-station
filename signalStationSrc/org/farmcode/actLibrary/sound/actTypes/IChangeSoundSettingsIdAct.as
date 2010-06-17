package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface IChangeSoundSettingsIdAct extends IUniversalAct
	{
		function get id(): String;
		function get path(): String;
		function get loadFromSettings(): Boolean;
		function get storageEnabled(): Boolean;
	}
}