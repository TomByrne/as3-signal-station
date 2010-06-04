package au.com.thefarmdigital.delayedDraw
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class DelayedDrawSprite extends Sprite implements IDrawable
	{
		/**
		 * @inheritDoc
		 */
		public function get drawDisplay():DisplayObject{
			return this;
		}
		public function get readyForDraw():Boolean{
			return stage!=null;
		}
		
		/**
		 * Whether the DelayedDrawSprite has been initialised yet 
		 */
		protected function get initialised(): Boolean {
			return this.helper.initialised;
		}
		
		private var _helper: DelayedDrawDisplayHelper;
		
		public function DelayedDrawSprite()
		{
			super();
			this.ensureHelperCreated();
		}
		
		protected function get helper(): DelayedDrawDisplayHelper
		{
			this.ensureHelperCreated();
			return this._helper;
		}
		
		protected function ensureHelperCreated(): void
		{
			if (this._helper == null)
			{
				this._helper = new DelayedDrawDisplayHelper(this);
				this._helper.addEventListener(Event.INIT, this.handleInit);
				this._helper.start();
			}
		}
		
		private function handleInit(event: Event): void
		{
			this.helper.removeEventListener(Event.INIT, this.handleInit);
			this.initialise();
		}
		
		/**
		 * The invalidate method flags this view to be redrawn on the next frame. It should be 
		 * called instead of calling <code>draw()</code> directly, meaning that if multiple visual 
		 * properties change, the (usually processor heavy) draw method only gets called once. There 
		 * will be a one frame delay between calling invalidate and the draw method being called, if 
		 * you want to call draw immediately, see the validate method.
		 * 
		 * @see validate
		 */
		protected function invalidate():void
		{
			this.helper.invalidate();
		}
		/**
		 * The validate method will clear any calls to invalidate and call the draw method (if <code>invalidate()</code> has been called or if
		 * <code>forceDraw</code> is true). The <code>draw()</code> method should never be called directly, if you need immediate execution,
		 * call <code>validate(true);</code> (although it's not recommended to write code which relies on this).
		 * 
		 * @param forceDraw specifies whether draw() should be called regardless of whether the view is invalid.
		 */
		public function validate(forceDraw:Boolean=false):void
		{
			this.helper.validate(forceDraw);
		}
		
		/**
		 * Will force the initialise function to be called if it hasn't be called yet or even if the 
		 * DelayedDrawSprite is not on the stage.
		 */
		final public function ensureInitialised(): void
		{
			this.helper.ensureInitialised();
		}
		
		/**
		 * @inheritDoc
		 */
		final public function commitDraw(): void
		{
			this.ensureInitialised();
			this.draw();
		}
		
		/**
		 * Builds the visual elements and creates the display. Initialise will be called only once
		 * in the lifetime of a DelayedDrawSprite. Initialise is called as late as possible, just
		 * before the first draw function is called. If initialisation is required before being
		 * added to the stage then call <code>ensureInitialised()</code>, alternatively call 
		 * <code>validate(true)</code> to force initialisation and draw.
		 */
		protected function initialise(): void
		{
			
		}
		
		/**
		 * The draw method should be overridden within subclasses of the DelayedDrawSprite class, 
		 * it should contain all logic for visual layout and drawing. Conventionally, if the draw 
		 * method becomes very large, it will be broken down into several parts, with boolean flags 
		 * indicating which parts are invalid. This means that when <code>invalidate()</code> gets 
		 * called, the appropriate boolean will be flagged and the draw method will contain an 
		 * <code>if</code> statement testing that boolean, executing if the boolean is flagged, and			
		 * finally resetting the boolean.
		 */
		protected function draw():void
		{
			
		}
	}
}