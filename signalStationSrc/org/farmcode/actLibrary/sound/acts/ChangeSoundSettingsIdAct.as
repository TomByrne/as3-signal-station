package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.sound.actTypes.IChangeSoundSettingsIdAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class ChangeSoundSettingsIdAct extends UniversalAct implements IChangeSoundSettingsIdAct
	{
		protected var _id: String;
		protected var _path: String = "/";
		protected var _loadFromSettings: Boolean = true;
		protected var _storageEnabled: Boolean = false;
		
		public function ChangeSoundSettingsIdAct(){
		}
		
		[Property(toString="true",clonable="true")]
		public function set storageEnabled(storageEnabled: Boolean): void
		{
			this._storageEnabled = storageEnabled;
		}
		public function get storageEnabled(): Boolean
		{
			return this._storageEnabled;
		}
		
		[Property(toString="true",clonable="true")]
		public function get id(): String
		{
			return this._id;
		}
		public function set id(id: String): void
		{
			this._id = id;
		}
		
		[Property(toString="true",clonable="true")]
		public function get path(): String
		{
			return this._path;
		}
		public function set path(path: String): void
		{
			this._path = path;
		}
		
		[Property(toString="true",clonable="true")]
		public function get loadFromSettings(): Boolean
		{
			return this._loadFromSettings;
		}
		public function set loadFromSettings(loadFromSettings: Boolean): void
		{
			this._loadFromSettings = loadFromSettings;
		}
	}
}