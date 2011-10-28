package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.*;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.*;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.*;
	import org.tbyrne.factories.*;

	public class NativeAssetFactory implements IAssetFactory
	{
		// mapped DisplayObject -> IDisplayObject
		private static var cache:Dictionary = new Dictionary(true);
		
		
		public function get skinContainer():DisplayObjectContainer{
			return _skinContainer;
		}
		public function set skinContainer(value:DisplayObjectContainer):void{
			_skinContainer = value;
		}
		
		private var _skinContainer:DisplayObjectContainer;
		private var bundles:Array;
		
		public var pixelSnapping:Boolean;
		public var noFilters:Boolean;
		
		public function NativeAssetFactory(skinContainer:DisplayObjectContainer=null){
			this.skinContainer = skinContainer;
		}
		public function getCoreSkin(coreSkinLabel:String):IAsset{
			var ret:* = _skinContainer.getChildByName(coreSkinLabel);
			var type:Class = ret["constructor"];
			CONFIG::debug{
				checkFactoryType(type);
			}
			return getNew(new type());
		}
		public function createContainer():IDisplayObjectContainer{
			return getNewByType(IDisplayObjectContainer);
		}
		public function createBitmap():IBitmap{
			return getNewByType(IBitmap);
		}
		public function createHitArea():ISprite{
			var ret:SpriteAsset = getNewByType(ISprite);
			ret.pixelSnapping = pixelSnapping;
			ret.noFilters = noFilters;
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
					Log.error( "NativeAssetFactory.checkFactoryType: Flash assets must be 'Exported for Actionscript' to be clonable");
				}
			}
		}
		
		private function init():void{
			// this must never list a superclass before a subclass (i.e. SpriteAsset mustn't be above MovieClipAsset)
			bundles = [	new TypeBundle(BitmapAsset, [IBitmap], Bitmap),
						new TypeBundle(TextFieldAsset, [ITextField], TextField),
						new TypeBundle(MovieClipAsset, [IMovieClip], MovieClip),
						new TypeBundle(StageAsset, [IStage], Stage),
						new TypeBundle(SpriteAsset, [ISprite,IDisplayObjectContainer], Sprite),
						new TypeBundle(LoaderAsset, [ILoader], Loader),
						new TypeBundle(InteractiveObjectAsset, [IInteractiveObject], SimpleButton),
						new TypeBundle(VideoAsset, [IVideo], Video),
						new TypeBundle(DisplayObjectAsset, [IDisplayObject], Shape)];
		}
		
		public function getNew(displayObject:*):*{
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
						cast.parent = getNew(displayObject.parent); // this provides the entire app with a reference to the IStage
					}
				}
				ret.pixelSnapping = pixelSnapping;
				ret.noFilters = noFilters;
				return ret;
			}else{
				return null;
			}
		}
		public function getExisting(displayObject:*):*{
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
			ret.pixelSnapping = pixelSnapping;
			ret.noFilters = noFilters;
			cache[display] = ret;
			return ret;
		}
		internal function getCloneFactory(from:DisplayObjectAsset):IInstanceFactory{
			if(!bundles)init();
			
			var displayClass:Class = from.displayObject["constructor"];
			CONFIG::debug{
				checkFactoryType(displayClass);
			}
			
			// nesting the factories makes sure that the factory prop gets set first
			
			var initFact:InstanceFactory = new InstanceFactory(getBundleByAsset(from).assetClass,{factory:this});
			
			var lateProps:Dictionary = new Dictionary();
			lateProps["displayObject"] = new InstanceFactory(displayClass);
			lateProps["pixelSnapping"] = pixelSnapping;
			lateProps["noFilters"] = noFilters;
			var proxyFact:ProxyInstanceFactory = new ProxyInstanceFactory(initFact,lateProps,true);
			
			return proxyFact;
		}
		
		
		private function getBundleByDisplay(display:*):TypeBundle{
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
				Log.error( "NativeAssetFactory.returnTo: displayObject property has been set outside of NativeAssetFactory");
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