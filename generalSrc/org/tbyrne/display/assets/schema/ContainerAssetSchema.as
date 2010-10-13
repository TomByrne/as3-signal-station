package org.tbyrne.display.assets.schema
{
	import org.tbyrne.display.assets.schemaTypes.IContainerAssetSchema;
	
	public class ContainerAssetSchema extends AbstractDisplayAssetSchema implements IContainerAssetSchema
	{
		
		public function get childSchemas():Array{
			return _childSchemas;
		}
		override public function set assetName(value:String):void{
			if(_assetName != value){
				super.assetName = value;
				fillPaths();
			}
		}
		override public function set parentPath(value:String):void{
			if(_parentPath != value){
				super.parentPath = value;
				fillPaths();
			}
		}
		
		private var _childSchemas:Array;
		private var _thisPath:String;
		
		public function ContainerAssetSchema(assetName:String=null, x:Number=NaN, y:Number=NaN, childSchemas:Array=null, fallbackToGroup:Boolean=false){
			super(assetName, x, y, fallbackToGroup);
			setChildSchemas(childSchemas);
		}
		public function addChildSchema(child:AbstractDisplayAssetSchema):void{
			if(!_childSchemas){
				_childSchemas = [];
			}
			_childSchemas.push(child);
			child.parentPath = _thisPath;
		}
		
		protected function setChildSchemas(value:Array):void{
			if(_childSchemas){
				for each(var child:AbstractDisplayAssetSchema in _childSchemas){
					child.parentPath = null;
				}
			}
			_childSchemas = value;
			if(_childSchemas){
				fillPaths();
			}
		}
		protected function fillPaths():void{
			var path:String = assetPath;
			for each(var child:AbstractDisplayAssetSchema in _childSchemas){
				child.parentPath = path;
			}
		}
	}
}