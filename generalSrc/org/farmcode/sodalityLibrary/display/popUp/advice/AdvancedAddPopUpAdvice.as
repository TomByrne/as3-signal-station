package org.farmcode.sodalityLibrary.display.popUp.advice
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IAdvancedAddPopUpAdvice;
	
	public class AdvancedAddPopUpAdvice extends AddPopUpAdvice implements IAdvancedAddPopUpAdvice
	{
		private var _popUpParent: DisplayObjectContainer;
		private var _bgTransitionTime: Number;
		private var _bgFillColour: Number;
		private var _bgAlpha: Number;
		private var _keepInCentre: Boolean;
		private var _centre: Boolean;
		private var _positioningOffsets: Point;
		private var _focusable: Boolean;
		
		public function AdvancedAddPopUpAdvice(displayPath:String=null, display:DisplayObject=null)
		{
			super(displayPath, display);
			
			this.focusable = true;
			this.keepInCentre = false;
			this.centre = false;
		}
		
		[Property(toString="true",clonable="true")]
		public function get popUpParent():DisplayObjectContainer
		{
			return this._popUpParent;
		}
		public function set popUpParent(popUpParent: DisplayObjectContainer): void
		{
			this._popUpParent = popUpParent;
		}
		
		[Property(toString="true",clonable="true")]
		public function get centre():Boolean
		{
			return this._centre;
		}
		public function set centre(_centre: Boolean): void
		{
			this._centre = _centre;
		}
		
		[Property(toString="true",clonable="true")]
		public function get focusable():Boolean
		{
			return this._focusable;
		}
		public function set focusable(value: Boolean): void
		{
			this._focusable = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get keepInCentre():Boolean
		{
			return this._keepInCentre;
		}
		public function set keepInCentre(keepInCentre: Boolean): void
		{
			this._keepInCentre = keepInCentre;
		}
		
		[Property(toString="true",clonable="true")]
		public function get positioningOffsets():Point
		{
			return this._positioningOffsets;
		}
		public function set positioningOffsets(positioningOffsets: Point): void
		{
			this._positioningOffsets = positioningOffsets;
		}
		
		[Property(toString="true",clonable="true")]
		public function get bgFillColour():Number
		{
			return this._bgFillColour;
		}
		public function set bgFillColour(bgFillColour: Number): void
		{
			this._bgFillColour = bgFillColour;
		}
		
		[Property(toString="true",clonable="true")]
		public function get bgAlpha():Number
		{
			return this._bgAlpha;
		}
		public function set bgAlpha(bgAlpha: Number): void
		{
			this._bgAlpha = bgAlpha;
		}
		
		[Property(toString="true",clonable="true")]
		public function set bgTransitionTime(bgTransitionTime: Number): void
		{
			this._bgTransitionTime = bgTransitionTime;
		}
		public function get bgTransitionTime():Number
		{
			return this._bgTransitionTime;
		}
	}
}