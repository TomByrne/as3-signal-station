package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxScene;
	import org.farmcode.sodalityPlatformEngine.scene.events.SceneEvent;
	import org.farmcode.sodalityPlatformEngine.states.StateObject;
	
	import flash.geom.Rectangle;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	import org.farmcode.sodality.advice.IAdvice;
	
	public class Scene extends StateObject implements IScene, IParallaxScene
	{
		[Property(toString="true",clonable="true")]
		public function get items():Array{
			return _items;
		}
		public function set items(value:Array):void{
			//if(value!=_items){
				_items = value;
			//}
		}
		
		
		[Property(toString="true",clonable="true")]
		public function get cullBuffer():Rectangle{
			return _cullBuffer
		}
		public function set cullBuffer(value:Rectangle):void{
			//if(value!=_cullBuffer){
				_cullBuffer = value;
			//}
		}
		
		[Property(toString="true",clonable="true")]
		public function get cameraBounds():Rectangle{
			return _cameraBounds;
		}
		public function set cameraBounds(value:Rectangle):void{
			//if(_cameraBounds){
				_cameraBounds = value;
			//}
		}
		
		private var _items:Array;
		private var _cullBuffer:Rectangle;
		protected var _cameraBounds:Rectangle;
		
		public function Scene()
		{
			
		}
		
		public function setFocused(value: Boolean, before: IAdvice = null, after: IAdvice = null): void
		{
			this.setStatefulPropertyActive(SceneStatefulProperties.FOCUS, value, before, after);
		}
		
		override protected function registerStatefulProperties(): void
		{
			this.registerStatefulProperty(SceneStatefulProperties.CORE, false);
			this.registerStatefulProperty(SceneStatefulProperties.FOCUS, true, false);
		}
		
		public function dispose(before: IAdvice = null, after: IAdvice = null): void
		{
			this.dispatchEvent(new SceneEvent(SceneEvent.DISPOSE));
			this.setCurrentState(null, before, after);
		}
		
		public function init(before: IAdvice = null, after: IAdvice = null): void
		{
			this.setToDefaultState(before, after);
		}
		
		/*public function getItem(id:String):ISceneItem{
			for each(var item:ISceneItem in _items){
				if(item.id==id)return item;
			}
			return null;
		}*/
		
		override public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}