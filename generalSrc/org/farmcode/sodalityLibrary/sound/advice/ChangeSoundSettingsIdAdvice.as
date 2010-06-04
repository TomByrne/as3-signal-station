package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IChangeSoundSettingsIdAdvice;

	public class ChangeSoundSettingsIdAdvice extends Advice implements IChangeSoundSettingsIdAdvice
	{
		protected var _id: String;
		protected var _path: String;
		protected var _loadFromSettings: Boolean;
		protected var _storageEnabled: Boolean;
		
		public function ChangeSoundSettingsIdAdvice(abortable:Boolean=true)
		{
			super(abortable);
			
			this.loadFromSettings = true;
			this.id = null;
			this.path = "/";
			this.storageEnabled = false;
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