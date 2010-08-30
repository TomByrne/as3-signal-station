package org.farmcode.display.assets.schema
{
	import org.farmcode.display.assets.IAssetFactory;
	import org.farmcode.display.assets.assetTypes.*;
	import org.farmcode.display.assets.schemaTypes.*;
	import org.farmcode.instanceFactory.IInstanceFactory;

	public class AbstractSchemaAssetFactory implements IAssetFactory
	{
		private var _containerProto:ContainerAssetSchema;
		private var _bitmapProto:BitmapAssetSchema;
		private var _hitAreaProto:RectangleAssetSchema;
		
		public function get containerSchema():IContainerAssetSchema{
			return _containerSchema;
		}
		
		private var _containerSchema:IContainerAssetSchema;
		
		public function AbstractSchemaAssetFactory(containerSchema:IContainerAssetSchema){
			_containerSchema = containerSchema;
		}
		public function getCoreSkin(coreSkinLabel:String):IAsset{
			return createAssetFromSchema(findSchemaWithin(_containerSchema, coreSkinLabel));
		}
		public function createContainer():IContainerAsset{
			if(!_containerProto){
				_containerProto = new ContainerAssetSchema();
			}
			return createAssetFromSchema(_containerProto) as IContainerAsset;
		}
		public function createBitmap():IBitmapAsset{
			if(!_bitmapProto){
				_bitmapProto = new BitmapAssetSchema();
			}
			return createAssetFromSchema(_bitmapProto) as IBitmapAsset;
		}
		public function createHitArea():ISpriteAsset{
			if(!_hitAreaProto){
				_hitAreaProto = new RectangleAssetSchema(null,NaN,NaN,NaN,NaN,null,false);
			}
			return createAssetFromSchema(_hitAreaProto) as ISpriteAsset;
		}
		public function destroyAsset(asset:IAsset):void{
			throw new Error();
		}
		
		
		public function createAssetFromSchema(schema:IAssetSchema):IAsset{
			throw new Error();
		}
		protected function attemptToCreateChildren(schema:IAssetSchema):Array{
			var contSchema:IContainerAssetSchema = (schema as IContainerAssetSchema);
			if(contSchema && contSchema.childSchemas && contSchema.childSchemas.length){
				var children:Array = [];
				for each(var childSchema:IAssetSchema in contSchema.childSchemas){
					children.push(createAssetFromSchema(childSchema));
				}
				return children;
			}
			return null;
		}
		protected function findSchemaWithin(group:IContainerAssetSchema, assetName:String):IAssetSchema{
			for each(var schema:IAssetSchema in group.childSchemas){
				if(schema.assetName==assetName){
					return schema;
				}
			}
			return null;
		}
		internal function getCloneFactory(from:AbstractSchemaBasedAsset):IInstanceFactory{
			/*var ret:MultiInstanceFactory = new MultiInstanceFactory(getAssetClass(from));
			var props:Dictionary = new Dictionary();
			props["factory"] = this;
			props["schema"] = from.schema;
			ret.addProperties(props);
			return ret;*/
			return new CloneAssetFactory(this,from.schema);
		}
		
		protected function getAssetClass(from:AbstractSchemaBasedAsset):Class{
			return from["constructor"]; // override me to optimise
		}
	}
}
import org.farmcode.acting.actTypes.IAct;
import org.farmcode.acting.acts.Act;
import org.farmcode.display.assets.assetTypes.IAsset;
import org.farmcode.display.assets.schema.AbstractSchemaAssetFactory;
import org.farmcode.display.assets.schema.AbstractSchemaBasedAsset;
import org.farmcode.display.assets.schemaTypes.IAssetSchema;
import org.farmcode.instanceFactory.IInstanceFactory;

class CloneAssetFactory implements IInstanceFactory{
	
	private var factory:AbstractSchemaAssetFactory;
	private var schema:IAssetSchema;
	
	public function CloneAssetFactory(factory:AbstractSchemaAssetFactory, schema:IAssetSchema){
		this.factory = factory;
		this.schema = schema;
	}
	
	public function createInstance():*{
		var ret:IAsset = factory.createAssetFromSchema(schema);
		if(_itemCreatedAct)_itemCreatedAct.perform(this,ret);
		return ret;
	}
	public function initialiseInstance(object:*):void{
		var cast:AbstractSchemaBasedAsset = (object as AbstractSchemaBasedAsset);
		cast.schema = schema;
	}
	public function matchesType(object:*):Boolean{
		var cast:AbstractSchemaBasedAsset = (object as AbstractSchemaBasedAsset);
		return (cast && cast.schema==schema);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get itemCreatedAct():IAct{
		if(!_itemCreatedAct)_itemCreatedAct = new Act();
		return _itemCreatedAct;
	}
	
	protected var _itemCreatedAct:Act;
}