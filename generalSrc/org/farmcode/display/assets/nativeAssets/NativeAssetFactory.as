package org.farmcode.display.assets.nativeAssets
{
	import flash.display.*;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.assets.*;
	import org.farmcode.display.assets.assetTypes.*;
	import org.farmcode.instanceFactory.*;

	public class NativeAssetFactory implements IAssetFactory
	{
		// mapped DisplayObject -> IDisplayAsset
		private static var cache:Dictionary = new Dictionary(true);
		
		
		public function get skinContainer():DisplayObjectContainer{
			return _skinContainer;
		}
		public function set skinContainer(value:DisplayObjectContainer):void{
			_skinContainer = value;
		}
		
		private var _skinContainer:DisplayObjectContainer;
		private var bundles:Array;
		
		public function NativeAssetFactory(skinContainer:DisplayObjectContainer=null){
			this.skinContainer = skinContainer;
		}
		public function getCoreSkin(coreSkinLabel:String):IAsset{
			var ret:DisplayObject = _skinContainer.getChildByName(coreSkinLabel);
			var type:Class = ret["constructor"];
			CONFIG::debug{
				checkFactoryType(type);
			}
			return getNew(new type());
		}
		public function createContainer():IContainerAsset{
			return getNewByType(IContainerAsset);
		}
		public function createBitmap():IBitmapAsset{
			return getNewByType(IBitmapAsset);
		}
		public function createHitArea():ISpriteAsset{
			var ret:SpriteAsset = getNewByType(ISpriteAsset);
			var sprite:Sprite = ret.displayObject as Sprite;
			sprite.graphics.beginFill(0,0);
			sprite.graphics.drawRect(0,0,10,10);
			sprite.graphics.endFill();
			return ret;
		}
		public function destroyAsset(asset:IAsset):void{
			//if(!bundles)init();
			var cast:NativeAsset = (asset as NativeAsset);
			cast.reset();
			returnTo(getBundleByAsset(asset).pool, cast);
		}
		
		CONFIG::debug{
			protected function checkFactoryType(type:Class):void{
				if(type==MovieClip || type==Shape || type==Sprite || type==SimpleButton){
					throw new Error("Flash assets must be 'Exported for Actionscript' to be clonable");
				}
			}
		}
		
		private function init():void{
			// this must never list a superclass before a subclass (i.e. SpriteAsset mustn't be above MovieClipAsset)
			bundles = [	new TypeBundle(BitmapAsset, [IBitmapAsset], Bitmap),
						new TypeBundle(TextFieldAsset, [ITextFieldAsset], TextField),
						new TypeBundle(MovieClipAsset, [IMovieClipAsset], MovieClip),
						new TypeBundle(StageAsset, [IStageAsset], Stage),
						new TypeBundle(SpriteAsset, [ISpriteAsset,IContainerAsset], Sprite),
						new TypeBundle(LoaderAsset, [ILoaderAsset], Loader),
						new TypeBundle(InteractiveObjectAsset, [IInteractiveObjectAsset], SimpleButton),
						new TypeBundle(VideoAsset, [IVideoAsset], Video),
						new TypeBundle(DisplayObjectAsset, [IDisplayAsset], Shape)];
		}
		
		public function getNew(displayObject:DisplayObject):*{
			if(displayObject){
				if(!bundles)init();
				var ret:NativeAsset = cache[displayObject];
				if(!ret){
					var bundle:TypeBundle = getBundleByDisplay(displayObject);
					ret = takeFrom(bundle.pool, bundle.assetClass);
					ret.display = displayObject;
					cache[displayObject] = ret;
					
					var cast:DisplayObjectAsset = (ret as DisplayObjectAsset);
					if(cast && displayObject.parent && displayObject.parent==displayObject.stage){
						cast.parent = getNew(displayObject.parent); // this provides the entire app with a reference to the IStageAsset
					}
				}
				return ret;
			}else{
				return null;
			}
		}
		public function getExisting(displayObject:DisplayObject):*{
			if(displayObject){
				if(!bundles)init();
				var ret:DisplayObjectAsset = cache[displayObject];
				return ret;
			}else{
				return null;
			}
		}
		public function getNewByType(type:Class):*{
			if(!bundles)init();
			var bundle:TypeBundle = getBundleByAssetInterface(type);
			var ret:NativeAsset = takeFrom(bundle.pool, bundle.assetClass);
			var display:* = new bundle.displayClass();
			ret.display = display;
			cache[display] = ret;
			return ret;
		}
		internal function getCloneFactory(from:DisplayObjectAsset):IInstanceFactory{
			if(!bundles)init();
			var ret:MultiInstanceFactory = new MultiInstanceFactory(getBundleByAsset(from).assetClass);
			
			var earlyProps:Dictionary = new Dictionary();
			earlyProps["factory"] = this;
			ret.addProperties(earlyProps);
			
			var displayClass:Class = from.displayObject["constructor"];
			CONFIG::debug{
				checkFactoryType(displayClass);
			}
			var lateProps:Dictionary = new Dictionary();
			lateProps["displayObject"] = new MultiInstanceFactory(displayClass);
			ret.addProperties(lateProps);
			
			ret.useChildFactories = true;
			return ret;
		}
		
		
		private function getBundleByDisplay(display:DisplayObject):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(display is type.displayClass){
					return type;
				}
			}
			return null;
		}
		private function getBundleByAsset(asset:IAsset):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(asset is type.assetClass){
					return type;
				}
			}
			return null;
		}
		private function getBundleByAssetInterface(assetInterface:Class):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(type.assetInterfaces.indexOf(assetInterface)!=-1){
					return type;
				}
			}
			return null;
		}
		private function takeFrom(pool:Array, klass:Class):NativeAsset{
			var ret:NativeAsset;
			if(!pool.length){
				ret =  (new klass(this) as NativeAsset);
			}else{
				ret = pool.shift()
			}
			return ret;
		}
		private function returnTo(pool:Array, asset:NativeAsset):void{
			var cached:IAsset = cache[asset.display];
			if(cached!=asset){
				throw new Error("displayObject property has been set outside of NativeAssetFactory");
			}
			delete cache[asset.display];
			asset.display = null;
			pool.push(asset);
		}
	}
}
class TypeBundle{
	public var pool:Array = [];
	public var assetClass:Class;
	public var assetInterfaces:Array;
	public var displayClass:Class;
	
	public function TypeBundle(assetClass:Class, assetInterfaces:Array, displayClass:Class){
		this.assetClass = assetClass;
		this.assetInterfaces = assetInterfaces;
		this.displayClass = displayClass;
	}
}