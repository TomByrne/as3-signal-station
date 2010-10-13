package org.tbyrne.display.assets.schema
{
	import org.tbyrne.display.assets.schemaTypes.IDisplayAssetSchema;
	import org.tbyrne.display.validation.ValidationFlag;

	public class AbstractDisplayAssetSchema implements IDisplayAssetSchema
	{
		public function get assetName():String{
			return _assetName;
		}
		public function set assetName(value:String):void{
			if(_assetName != value){
				_assetPathFlag.invalidate();
				_assetName = value;
			}
		}
		
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			_x = value;
		}
		
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			_y = value;
		}
		
		public function get fallbackToGroup():Boolean{
			return _fallbackToGroup;
		}
		public function set fallbackToGroup(value:Boolean):void{
			_fallbackToGroup = value;
		}
		
		public function get parentPath():String{
			return _parentPath;
		}
		public function set parentPath(value:String):void{
			if(_parentPath != value){
				_assetPathFlag.invalidate();
				_parentPath = value;
			}
		}
		public function get assetPath():String{
			_assetPathFlag.validate();
			return _assetPath;
		}
		
		protected var _assetPath:String;
		protected var _parentPath:String;
		protected var _assetPathFlag:ValidationFlag = new ValidationFlag(validateAssetPath,true);
		
		protected var _fallbackToGroup:Boolean;
		protected var _y:Number;
		protected var _x:Number;
		protected var _assetName:String;
		
		public function AbstractDisplayAssetSchema(assetName:String=null, x:Number=NaN, y:Number=NaN, fallbackToGroup:Boolean=false)
		{
			this.assetName = assetName;
			this.x = x;
			this.y = y;
			this.fallbackToGroup = fallbackToGroup;
		}
		protected function validateAssetPath():void{
			var newPath:String = (_assetName?_assetName:"..");
			if(_parentPath){
				newPath = _parentPath+"/"+newPath;
			}
			if(_assetPath!=newPath){
				setAssetPath(newPath);
			}
		}
		protected function setAssetPath(newPath:String):void{
			_assetPath = newPath;
		}
	}
}