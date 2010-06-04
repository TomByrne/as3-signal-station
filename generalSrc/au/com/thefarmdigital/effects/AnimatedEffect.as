package au.com.thefarmdigital.effects{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.core.DelayedCall;
	

	
	public class AnimatedEffect extends Effect
	{
		
		// subject can be any DisplayObject (so we can effect TextFields, Bitmaps, MovieClips, etc)
		override public function set subject(value:DisplayObject):void {
			if(super.subject != value && value != null){
				if(subject){
					subject.removeEventListener(Event.ADDED_TO_STAGE,onSubjectAdded);
					subject.removeEventListener(Event.REMOVED_FROM_STAGE,onSubjectRemoved);
					onSubjectRemoved();
				}
				super.subject = value;
				if(subject.stage)onSubjectAdded();
				subject.addEventListener(Event.ADDED_TO_STAGE,onSubjectAdded);
				subject.addEventListener(Event.REMOVED_FROM_STAGE,onSubjectRemoved);
				invalidate();
			}
		}
		override public function get subject():DisplayObject {
			return super.subject;
		}
		// animated (when set to true) will redraw/reposition the entire bitmap on every frame
		public function set animated(to:Boolean):void {
			if(_animated !=to) {
				_animated = to;
				if(to && !_animateCall)doAnimate();
				else if(!to && _animateCall){
					_animateCall.clear();
					_animateCall = null;
				}
			}
		}		
		public function get animated():Boolean {
			return _animated;
		}
		// binds the position of the Bitmap to the subject
		public function set autoPosition(to:Boolean):void {
			if(_autoPosition !=to) {
				_autoPosition = to;
				if(to && !_positionCall)doPosition();
				else if(!to && _positionCall){
					_positionCall.clear();
					_positionCall = null;
				}
			}
		}		
		public function get autoPosition():Boolean {
			return _autoPosition;
		}
		public function set x(value:Number):void{
			if(_x!=value){
				_x = value;
				lightInvalidate();
			}
		}
		public function get x():Number{
			return _x;
		}
		public function set y(value:Number):void{
			if(_y!=value){
				_y = value;
				lightInvalidate();
			}
		}
		public function get y():Number{
			return _y;
		}
		public function set alpha(value:Number):void{
			if(_renderArea.alpha!=value){
				_renderArea.alpha = value;
			}
		}
		public function get alpha():Number{
			return _renderArea.alpha;
		}
		public function get renderArea():Bitmap{
			return _renderArea;
		}
		protected function set subjectBounds(value:Rectangle):void {
			if(!_subjectBounds || !_subjectBounds.equals(value)) {
				_subjectBounds = value;
			}
		}
		protected function get subjectBounds():Rectangle {
			return _subjectBounds;
		}
		
		private var _x						: Number = 0;
		private var _y						: Number = 0;
		private var _subject				: DisplayObject;
		private var _animateCall			: DelayedCall;
		private var _positionCall			: DelayedCall;
		private var _renderArea				: Bitmap = new Bitmap(null,PixelSnapping.AUTO,true);
		private var _animated				: Boolean = false;
		private var _autoPosition			: Boolean;
		protected var _bitmapChanged		: Boolean = false;
		private var _subjectBounds			: Rectangle;
		protected var _renderOffset			: Point = new Point();
		
		public function AnimatedEffect( subject:DisplayObject=null ){
			this.subject = subject;
			autoPosition = true;
		}
		protected function onSubjectAdded(e:Event=null):void{
			if(_renderArea.parent!=subject.parent){
				if(_renderArea.parent)_renderArea.parent.removeChild(_renderArea);
				subject.parent.addChild(_renderArea);
			}
			invalidate();
		}
		protected function onSubjectRemoved(e:Event=null):void{
			remove();
		}
		override public function remove():void{
			if(_renderArea.parent)_renderArea.parent.removeChild(_renderArea);
			if(_animateCall){
				_animateCall.clear();
				_animateCall = null;
			}
			if(_positionCall){
				_positionCall.clear();
				_positionCall = null;
			}
			_bitmapChanged = true;
		}

		/** redraws bitmapData and position
		 */
		protected function invalidate():void {
			_bitmapChanged = true;
			var delayedCall:DelayedCall = new DelayedCall(_render, 1, false);
			delayedCall.begin();
		}
		/** only redraws position
		 */
		protected function lightInvalidate():void {			
			var delayedCall:DelayedCall = new DelayedCall(_render, 1, false);
			delayedCall.begin();
		}
		protected function doAnimate():void {
			if(!_animateCall)_animateCall = new DelayedCall(doAnimate, 1, false);
			_animateCall.begin();
			createBitmap();
		}
		protected function doPosition():void {
			if(!_positionCall)_positionCall = new DelayedCall(doPosition, 1, false);
			_positionCall.begin();
			position();
		}
		override public function render() : void {
			_bitmapChanged = true;
			_render();
		}
		protected function _render() : void {		
			if(_bitmapChanged)createBitmap();
			position();
		}
		protected function position():void {
			if(subject && _renderArea.stage && subject.parent){
				subjectBounds = subject.getBounds(_renderArea.parent);
				_renderArea.x = _subjectBounds.x+x+_renderOffset.x;
				_renderArea.y = _subjectBounds.y+y+_renderOffset.y;
			}
		}
		protected function createBitmap():void {
			// override me
			_bitmapChanged = false;
		}
	}
}