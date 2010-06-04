package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	/**
	 * The FileBrowser control contains a two Button subcontrols (named label and browseButton),
	 * and it displays them alongside one-another. When either Button is clicked a file browse
	 * dialog is opened for the user to select a file to upload.
	 */
	public class FileBrowser extends Control{
		public static const IMAGE_FILTERS: Array = [ new FileFilter("Images (*.jpe, *.jpeg, *.jpg, *.gif, *.png)", "*.jpe;*.jpeg;*.jpg;*.gif;*.png") ];
		public static const FLASH_IMAGE_FILTERS: Array = [ new FileFilter("Flash Images (*.jpe, *.jpeg, *.jpg, *.gif, *.png, *.swf)", "*.jpe;*.jpeg;*.jpg;*.gif;*.png;*.swf") ];
		
		public function get horizontalGap():Number{
			return _horizontalGap;
		}
		public function set horizontalGap(value:Number):void{
			if(_horizontalGap!=value){
				_horizontalGap = value;
				invalidate();
			}
		}
		public function get label():Button{
			return _label;
		}
		public function set label(value:Button):void{
			if(_label!=value){
				if(_label)_label.removeEventListener(MouseEvent.CLICK,browseHandler);
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				value.addEventListener(MouseEvent.CLICK,browseHandler);
				_label = value;
				invalidate();
			}
		}
		public function get browseButton():Button{
			return _browseButton;
		}
		public function set browseButton(value:Button):void{
			if(_browseButton!=value){
				if(_browseButton)_browseButton.removeEventListener(MouseEvent.CLICK,browseHandler);
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				value.addEventListener(MouseEvent.CLICK,browseHandler);
				_browseButton = value;
				_browseButton.tabIndex = _tabIndex;
				invalidate();
			}
		}
		public function set fileReference(to: FileReference):void{
			if (to != this._fileReference || this._fileReference == null) {
				if (this._fileReference != null) {
					_fileReference.removeEventListener(Event.SELECT,onSelectFile);
					_fileReference.removeEventListener(Event.CANCEL,onSelectFile);
				}
				if (to) {
					this._fileReference = to;
				} else {
					this._fileReference = new FileReference();
				}
				_fileReference.addEventListener(Event.SELECT,onSelectFile);
				_fileReference.addEventListener(Event.CANCEL,onSelectFile);
				this.invalidate();
				dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
			}
		}
		public function get fileReference():FileReference{
			return _fileReference;
		}
		override public function get tabIndex():int{
			return _tabIndex;
		}
		override public function set tabIndex(to:int):void{
			_tabIndex = to;
			if(_browseButton)_browseButton.tabIndex = to;
		}
		override public function get highlit():Boolean{
			return _highlit;
		}
		override public function set highlit(to:Boolean):void{
			_highlit = to;
			if(_browseButton)_browseButton.highlit = to;
			if(_label)_label.highlit = to;
		}
		override public function getValidationValue(validityKey:String=null):*{
			return fileReference;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			fileReference = value;
		}
		
		protected var _label:Button;
		protected var _browseButton:Button;
		protected var _tabIndex:Number;
		protected var _fileReference:FileReference;
		protected var _horizontalGap:Number = 2;
		
		public var fileFilters:Array;
		public var browsingMessage:String = "browsing...";
		
		public function FileBrowser(){
			if(_label && _browseButton){
				_horizontalGap = Math.max(_browseButton.x-_label.x-_label.width,0);
			}
			clear();
		}
		override public function clear():void{
			this.fileReference = null;
		}
		override protected function draw():void{
			if(_label)
			{
				try{
					_label.label = _fileReference.name;
				}catch(e:Error){
					_label.label = "";
				}
				
				if (_browseButton){
					_label.y = (height-_label.height)/2;
					_browseButton.y = (height-_browseButton.height)/2;
					_label.x = 0;
					_label.width = width-_horizontalGap-_browseButton.width;
					_browseButton.x = _label.width+_horizontalGap;
				}
			}
		}
		protected function browseHandler(e:Event):void{
			highlit = false;
			browse();
		}
		public function browse():void{
			if(_label)_label.label = browsingMessage;
			_fileReference.browse(fileFilters);
		}
		protected function onSelectFile(e:Event=null):void{
			this.invalidate();
			this.dispatchEvent(new ControlEvent(ControlEvent.VALUE_CHANGE));
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
		}	
	}
}