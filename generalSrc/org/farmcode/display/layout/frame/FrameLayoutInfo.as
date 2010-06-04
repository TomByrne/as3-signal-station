package org.farmcode.display.layout.frame
{
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Fit;
	import org.farmcode.display.constants.Scale;
	import org.farmcode.display.layout.core.MarginLayoutInfo;

	public class FrameLayoutInfo extends MarginLayoutInfo implements IFrameLayoutInfo
	{
		[Inspectable(name="Anchor", category="Styles",defaultValue="C", 
			enumeration="C,TL,T,TR,L,R,BL,B,BR",type="List")]
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			_anchor = value;
		}
		[Inspectable(name="Fit Policy", category="Styles",defaultValue="fitStretch", 
			enumeration="fitStretch,fitInside,fitExact",type="List")]
		public function get fitPolicy():String{
			return _fitPolicy;
		}
		public function set fitPolicy(value:String):void{
			_fitPolicy = value;
		}
		public function get scalePolicy():String{
			return (_scaleXPolicy==_scaleYPolicy?_scaleXPolicy:null);
		}
		public function set scalePolicy(value:String):void{
			_scaleXPolicy = _scaleYPolicy = value;
		}
		[Inspectable(name="Scale X Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleXPolicy():String{
			return _scaleXPolicy;
		}
		public function set scaleXPolicy(value:String):void{
			_scaleXPolicy = value;
		}
		[Inspectable(name="Scale Y Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleYPolicy():String{
			return _scaleYPolicy;
		}
		public function set scaleYPolicy(value:String):void{
			_scaleYPolicy = value;
		}
		
		protected var _anchor:String = Anchor.CENTER;
		protected var _fitPolicy:String = Fit.EXACT;
		protected var _scaleXPolicy:String = Scale.ALWAYS;
		protected var _scaleYPolicy:String = Scale.ALWAYS;
		
		public function FrameLayoutInfo(anchor:String=null, fitPolicy:String=null, scalePolicy:String=null){
			if(anchor)this.anchor = anchor;
			if(fitPolicy)this.fitPolicy = fitPolicy;
			if(scalePolicy)this.scalePolicy = scalePolicy;
		}
		
	}
}