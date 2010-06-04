package org.farmcode.sodalityPlatformEngine.structs.items
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.farmcode.sodality.advice.IAdvice;
	
	public class InteractiveSceneItem extends AdviceDispatcherSceneItem
	{
		private var _image: Sprite;
		private var _parallaxContainer:DisplayObjectContainer;
		
		public function InteractiveSceneItem(){
			super();
			_parallaxDisplay.display = _parallaxContainer = new Sprite();
		}
		
		public function set clickAdvice(clickAdvice: IAdvice): void
		{
			if(clickAdvice)this.setDispatchedAdvices(MouseEvent.CLICK, [clickAdvice]);
			else this.removeDispatchedAdvices(MouseEvent.CLICK);
		}
		
		public function set rollOverAdvice(rollOverAdvice: IAdvice): void
		{
			if(rollOverAdvice)this.setDispatchedAdvices(MouseEvent.ROLL_OVER, [rollOverAdvice]);
			else this.removeDispatchedAdvices(MouseEvent.ROLL_OVER);
		}
		
		public function set rollOutAdvice(rollOutAdvice: IAdvice): void
		{
			if(rollOutAdvice)this.setDispatchedAdvices(MouseEvent.ROLL_OUT, [rollOutAdvice]);
			else this.removeDispatchedAdvices(MouseEvent.ROLL_OUT);
		}
		
		public function get image():Sprite{
			return _image;
		}
		public function set image(value:Sprite):void{
			if(_image!=value){
				var triggerId:String;
				if(_image){
					for(triggerId in dispatchingAdvices){
						_image.removeEventListener(triggerId,handleDisplayEvent);
					}
					_parallaxContainer.removeChild(_image);
				}
				_image = value;
				if(_image){
					_parallaxContainer.addChild(value);
					_image.useHandCursor = true;
					_image.mouseEnabled = true;
					_image.buttonMode = true;
					for(triggerId in dispatchingAdvices){
						_image.addEventListener(triggerId,handleDisplayEvent);
					}
				}
			}
		}
		
		override public function addDispatchedAdvice(triggerId:String, advice:IAdvice):void
		{
			super.addDispatchedAdvice(triggerId, advice);
			if(_image){
				_image.addEventListener(triggerId,handleDisplayEvent);
			}
		}
		
		override public function removeDispatchedAdvice(triggerId:String, advice:IAdvice):Boolean
		{
			var result: Boolean = super.removeDispatchedAdvice(triggerId, advice);
			if(_image){
				_image.removeEventListener(triggerId,handleDisplayEvent);
			}
			return result;
		}
		
		protected function handleDisplayEvent(event: Event): void
		{
			var triggerId: String = event.type;
			this.dispatchAdvices(triggerId);
		}
	}
}