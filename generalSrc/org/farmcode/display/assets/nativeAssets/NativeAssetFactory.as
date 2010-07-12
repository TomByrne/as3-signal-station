package org.farmcode.display.assets.nativeAssets
{
	import flash.display.*;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.acts.NativeAct;
	import org.farmcode.display.assets.*;
	import org.farmcode.instanceFactory.*;

	public class NativeAssetFactory
	{
		// mapped DisplayObject -> IDisplayAsset
		private static var cache:Dictionary = new Dictionary(true);
		
		private static var bundles:Array;
		
		private static function init():void{
			// this must never list a superclass before a subclass (i.e. SpriteAsset mustn't be above MovieClipAsset)
			bundles = [	new TypeBundle(BitmapAsset, [IBitmapAsset], Bitmap),
						new TypeBundle(TextFieldAsset, [ITextFieldAsset], TextField),
						new TypeBundle(ShapeAsset, [IShapeAsset], Shape),
						new TypeBundle(MovieClipAsset, [IMovieClipAsset], MovieClip),
						new TypeBundle(StageAsset, [IStageAsset], Stage),
						new TypeBundle(SpriteAsset, [ISpriteAsset,IContainerAsset], Sprite),
						new TypeBundle(LoaderAsset, [ILoaderAsset], Loader),
						new TypeBundle(InteractiveObjectAsset, [IInteractiveObjectAsset], SimpleButton),
						new TypeBundle(VideoAsset, [IVideoAsset], Video)];
		}
		
		public static function getNew(displayObject:DisplayObject):*{
			if(displayObject){
				if(!bundles)init();
				var ret:DisplayObjectAsset = cache[displayObject];
				if(!ret){
					var bundle:TypeBundle = getBundleByDisplay(displayObject);
					ret = takeFrom(bundle.pool, bundle.assetClass);
					ret.displayObject = displayObject;
					cache[displayObject] = ret;
				}
				return ret;
			}else{
				return null;
			}
		}
		public static function getExisting(displayObject:DisplayObject):*{
			if(displayObject){
				if(!bundles)init();
				var ret:DisplayObjectAsset = cache[displayObject];
				return ret;
			}else{
				return null;
			}
		}
		public static function getNewByType(type:Class):DisplayObjectAsset{
			if(!bundles)init();
			var bundle:TypeBundle = getBundleByAssetInterface(type);
			return takeFrom(bundle.pool, bundle.assetClass, bundle.displayClass);
		}
		public static function returnAsset(asset:IAsset):void{
			if(!bundles)init();
			var cast:DisplayObjectAsset = (asset as DisplayObjectAsset);
			returnTo(getBundleByAsset(asset).pool, cast);
		}
		internal static function getCloneFactory(from:DisplayObjectAsset):IInstanceFactory{
			if(!bundles)init();
			var ret:MultiInstanceFactory = new MultiInstanceFactory(getBundleByAsset(from).assetClass);
			var props:Dictionary = new Dictionary();
			var displayClass:Class = from.displayObject["constructor"];
			props["displayObject"] = new MultiInstanceFactory(displayClass);
			ret.addProperties(props);
			ret.useChildFactories = true;
			return ret;
		}
		
		
		private static function getBundleByDisplay(display:DisplayObject):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(display is type.displayClass){
					return type;
				}
			}
			return null;
		}
		private static function getBundleByAsset(asset:IAsset):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(asset is type.assetClass){
					return type;
				}
			}
			return null;
		}
		private static function getBundleByAssetInterface(assetInterface:Class):TypeBundle{
			for each(var type:TypeBundle in bundles){
				if(type.assetInterfaces.indexOf(assetInterface)!=-1){
					return type;
				}
			}
			return null;
		}
		private static function takeFrom(pool:Array, klass:Class, createDisplayObject:Class=null):DisplayObjectAsset{
			var ret:DisplayObjectAsset;
			if(!pool.length){
				ret =  (new klass() as DisplayObjectAsset);
			}else{
				ret = pool.shift()
			}
			if(createDisplayObject){
				ret.displayObject = new createDisplayObject();
				cache[ret.displayObject] = ret;
			}
			return ret;
		}
		private static function returnTo(pool:Array, asset:DisplayObjectAsset):void{
			var cached:IAsset = cache[asset.displayObject];
			if(cached!=asset){
				throw new Error("displayObject property has been set outside of NativeAssetFactory");
			}
			delete cache[asset.displayObject];
			asset.displayObject = null;
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