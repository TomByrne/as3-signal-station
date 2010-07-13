package org.farmcode.display.layout.frame
{
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Fit;
	import org.farmcode.display.constants.Scale;
	import org.farmcode.display.layout.core.MarginLayoutInfo;

	public class FrameLayoutInfo extends MarginLayoutInfo implements IFrameLayoutInfo
	{
		/**
		 * Determines how the view gets aligned aligned in the display area.
		 * options:
		 * 		L		- Left edge
		 * 		TL		- Top-left corner
		 * 		T		- Top edge
		 * 		TR		- Top-right corner
		 * 		R		- Right edge
		 * 		BL		- Bottom-left corner
		 * 		B		- Bottom edge
		 * 		BR		- Bottom-right corner
		 * 		C		- centered
		 */
		[Inspectable(name="Anchor", category="Styles",defaultValue="C", 
			enumeration="C,TL,T,TR,L,R,BL,B,BR",type="List")]
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			_anchor = value;
		}
		
		/**
		 * Determines which type of framing is used,
		 * all of these types can be restricted by the scalePolicy variable.
		 * options:
		 * 		fitStretch	- View will be stretched to fit into the display area.
		 * 		fitInside	- View will be scaled to completely fit inside the display
		 * 						area. This will allow the background to show through
		 * 						in the parts of the display area that are not covered
		 * 						by the ILayoutView.
		 * 		fitExact	- View will be scaled to fill the entire display area.
		 * 						The area which falls out of the display area viewing area
		 * 						must be clipped off by the View controlling this Layout.
		 
		 * @see scalePolicy
		 */
		[Inspectable(name="Fit Policy", category="Styles",defaultValue="fitStretch", 
			enumeration="fitStretch,fitInside,fitExact",type="List")]
		public function get fitPolicy():String{
			return _fitPolicy;
		}
		public function set fitPolicy(value:String):void{
			_fitPolicy = value;
		}
		
		/**
		 * Restricts how the view is scaled, this can also be accessed
		 * on a per axis basis via scalePolicyX and scalePolicyY.
		 * options:
		 * 		scaleAlways		- View will always be scaled to meet the needs of fitPolicy.
		 * 		scaleNever		- View (or specific axis) will never be scaled.
		 * 		scaleUpOnly		- Only allows scaling up.
		 * 		scaleDownOnly	- Only allows scaling down.
		 * 
		 * @see scalePolicyX, scalePolicyY
		 */
		public function get scalePolicy():String{
			return (_scaleXPolicy==_scaleYPolicy?_scaleXPolicy:null);
		}
		public function set scalePolicy(value:String):void{
			_scaleXPolicy = _scaleYPolicy = value;
		}
		
		/**
		 * @see scalePolicy
		 */
		[Inspectable(name="Scale X Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleXPolicy():String{
			return _scaleXPolicy;
		}
		public function set scaleXPolicy(value:String):void{
			_scaleXPolicy = value;
		}
		
		/**
		 * @see scalePolicy
		 */
		[Inspectable(name="Scale Y Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleYPolicy():String{
			return _scaleYPolicy;
		}
		public function set scaleYPolicy(value:String):void{
			_scaleYPolicy = value;
		}
		
		protected var _anchor:String = Anchor.CENTER;
		protected var _fitPolicy:String = Fit.INSIDE;
		protected var _scaleXPolicy:String = Scale.ALWAYS;
		protected var _scaleYPolicy:String = Scale.ALWAYS;
		
		public function FrameLayoutInfo(anchor:String=null, fitPolicy:String=null, scalePolicy:String=null){
			if(anchor)this.anchor = anchor;
			if(fitPolicy)this.fitPolicy = fitPolicy;
			if(scalePolicy)this.scalePolicy = scalePolicy;
		}
		
	}
}