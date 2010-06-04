package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IModifyParallaxItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	import org.farmcode.sodalityPlatformEngine.scene.advice.AbstractSceneItemAdvice;

	public class ModifyParallaxItemAdvice extends AbstractSceneItemAdvice implements IModifyParallaxItemAdvice
	{
		protected var _x: Number;
		protected var _y: Number;
		protected var _z: Number;
		protected var _rotation: Number;
		
		public function ModifyParallaxItemAdvice(sceneItemId:String=null, sceneItem:ISceneItem=null)
		{
			super(sceneItemId, sceneItem);
			
			this.x = NaN;
			this.y = NaN;
			this.z = NaN;
			this.rotation = NaN;
		}
		
		public function get item(): IParallaxItem
		{
			return this.sceneItem as IParallaxItem;
		}
		
		[Property(toString="true",clonable="true")]
		public function get x(): Number
		{
			return this._x;
		}
		public function set x(value: Number): void
		{
			this._x = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get y(): Number
		{
			return this._y;
		}
		public function set y(value: Number): void
		{
			this._y = value;
		}

		[Property(toString="true",clonable="true")]
		public function get z(): Number
		{
			return this._z;
		}
		public function set z(value: Number): void
		{
			this._z = value;
		}

		[Property(toString="true",clonable="true")]
		public function get rotation(): Number
		{
			return this._rotation;
		}
		public function set rotation(value: Number): void
		{
			this._rotation = value;
		}
	}
}