package org.farmcode.actLibrary.external.browser.acts
{
	import flash.geom.Rectangle;
	
	import org.farmcode.actLibrary.external.browser.actTypes.IOpenBrowserWindowAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class OpenBrowserWindowAct extends UniversalAct implements IOpenBrowserWindowAct
	{
		[Property(toString="true",clonable="true")]
		public function get windowURL(): String{
			return _windowURL;
		}
		public function set windowURL(value: String):void{
			_windowURL = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get windowName(): String{
			return _windowName;
		}
		public function set windowName(value: String):void{
			_windowName = value;
		}
		
		
		
		[Property(toString="true",clonable="true")]
		public function get windowWidth(): Number{
			return _windowWidth;
		}
		public function set windowWidth(value: Number):void{
			_windowWidth = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get windowHeight(): Number{
			return _windowHeight;
		}
		public function set windowHeight(value: Number):void{
			_windowHeight = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get windowX(): Number{
			return _windowX;
		}
		public function set windowX(value: Number):void{
			_windowX = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get windowY(): Number{
			return _windowY;
		}
		public function set windowY(value: Number):void{
			_windowY = value;
		}
		
		
		
		[Property(toString="true",clonable="true")]
		public function get copyHistory(): Boolean{
			return _copyHistory;
		}
		public function set copyHistory(value: Boolean):void{
			_copyHistory = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get windowIsResizable(): Boolean{
			return _windowIsResizable;
		}
		public function set windowIsResizable(value: Boolean):void{
			_windowIsResizable = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get displayChrome(): Boolean{
			return _displayChrome;
		}
		public function set displayChrome(value: Boolean):void{
			_displayChrome = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get displayScrollBars(): Boolean{
			return _displayScrollBars;
		}
		public function set displayScrollBars(value: Boolean):void{
			_displayScrollBars = value;
		}
		
		public function get displayLocationBar(): Boolean{
			return _displayChrome;
		}
		public function get displayMenuBar(): Boolean{
			return _displayChrome;
		}
		public function get displayStaturBar(): Boolean{
			return _displayChrome;
		}
		public function get displayToolBar(): Boolean{
			return _displayChrome;
		}
		
		private var _displayScrollBars:Boolean = true;
		private var _displayChrome:Boolean = true;
		private var _windowIsResizable:Boolean = true;
		private var _copyHistory:Boolean = false;
		private var _windowY:Number;
		private var _windowX:Number;
		private var _windowWidth:Number;
		private var _windowHeight:Number;
		private var _windowURL:String;
		private var _windowName:String;
		
		public function OpenBrowserWindowAct(windowURL:String=null, windowName:String=null, windowSize:Rectangle=null, windowIsResizable:Boolean=true, displayChrome:Boolean = true, displayScrollBars:Boolean = true){
			this.windowURL = windowURL;
			this.windowName = windowName;
			if(windowSize){
				windowWidth = windowSize.width;
				windowHeight = windowSize.height;
				windowX = windowSize.x;
				windowY = windowSize.y;
			}
			this.windowIsResizable = windowIsResizable;
			this.displayChrome = displayChrome;
			this.displayScrollBars = displayScrollBars;
		}
		
	}
}