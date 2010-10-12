package org.farmcode.display.assets.schema
{
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.schemaTypes.IContainerAssetSchema;
	
	use namespace DisplayNamespace;
	
	public class StandardAssetSchema implements IContainerAssetSchema
	{
		public function get childSchemas():Array{
			return _childSchemas;
		}
		
		private var _childSchemas:Array;
		
		public function StandardAssetSchema(){
			_childSchemas = [];
			
			CONFIG::debug{
				var debugDisplay:ContainerAssetSchema = createDebugList(AssetNames.DEBUG_DISPLAY,0,0,100,20,true);
				debugDisplay.childSchemas.push(createDebugList(AssetNames.CHILD_LIST,0,0,100,20,false));
				_childSchemas.push(debugDisplay);
			}
		}
		
		CONFIG::debug{
			protected function createDebugList(assetName:String, x:Number, y:Number, width:Number, height:Number, incGraph:Boolean):ContainerAssetSchema{
				var listBacking:RectangleAssetSchema = new RectangleAssetSchema(AssetNames.BACKING,0,0,width,height);
				var listChildren:Array = [listBacking,createDebugLabel(AssetNames.LIST_ITEM,0,0,width,height)];
				
				if(incGraph){
					var bitmap:BitmapAssetSchema = new BitmapAssetSchema(AssetNames.DEBUG_ITEM_BITMAP,0,0,200,200);
					var upperLabel:TextAssetSchema = new TextAssetSchema(AssetNames.DEBUG_GRAPH_UPPER_LABEL,0,0,20,20);
					// graph speed control
					// graph maximise control
					// graph save XML button
					var saveButton:ContainerAssetSchema = createLabel(AssetNames.DEBUG_GRAPH_COPY_BUTTON,0,0,40,20,"Copy XML");
					var graph:ContainerAssetSchema = new ContainerAssetSchema(AssetNames.DEBUG_GRAPH_DISPLAY,0,0,[bitmap,saveButton,upperLabel]);
					listChildren.push(graph);
				}
					
				var list:ContainerAssetSchema = new ContainerAssetSchema(assetName,x,y,listChildren);
				return list;
			}
			
			protected function createDebugLabel(assetName:String, x:Number, y:Number, width:Number, height:Number, initialText:String=null):ContainerAssetSchema{
				var labelBacking:RectangleAssetSchema = new RectangleAssetSchema(AssetNames.BACKING,0,0,width,height);
				var bitmap:BitmapAssetSchema = new BitmapAssetSchema(AssetNames.DEBUG_ITEM_BITMAP,0,0,width,height);
				var labelText:TextAssetSchema = new TextAssetSchema(AssetNames.LABEL_FIELD,0,0,width,height,initialText);
				var label:ContainerAssetSchema = new ContainerAssetSchema(assetName,x,y,[labelBacking,bitmap,labelText]);
				return label;
			}
		}
		
		protected function createLabel(assetName:String, x:Number, y:Number, width:Number, height:Number, initialText:String=null):ContainerAssetSchema{
			var labelBacking:RectangleAssetSchema = new RectangleAssetSchema(AssetNames.BACKING,0,0,width,height);
			var labelText:TextAssetSchema = new TextAssetSchema(AssetNames.LABEL_FIELD,0,0,width,height,initialText);
			var label:ContainerAssetSchema = new ContainerAssetSchema(assetName,x,y,[labelBacking,labelText]);
			return label;
		}
		
	}
}