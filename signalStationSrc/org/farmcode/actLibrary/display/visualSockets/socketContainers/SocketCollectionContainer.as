package org.farmcode.actLibrary.display.visualSockets.socketContainers
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.layout.ILayout;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class SocketCollectionContainer extends SocketContainer
	{
		
		public function get collectionDataProperty():String{
			return _socketCollContHelper.collectionDataProperty;
		}
		public function set collectionDataProperty(value:String):void{
			_socketCollContHelper.collectionDataProperty = value;
		}
		
		public function get collectionLayout():ILayout{
			return _collectionLayout;
		}
		public function set collectionLayout(value:ILayout):void{
			if(_collectionLayout!=value){
				var subject:ILayoutSubject;
				if(_collectionLayout){
					for each(subject in _socketCollContHelper.collectionSockets){
						_collectionLayout.removeSubject(subject);
					}
					if(_collectionLayoutSubject && super.layout){
						super.layout.removeSubject(_collectionLayoutSubject);
					}
					_collectionLayout.scopeView = null;
				}
				_collectionLayout = value;
				_collectionLayoutSubject = (value as ILayoutSubject);
				if(_collectionLayout){
					_collectionLayout.scopeView = this;
					for each(subject in _socketCollContHelper.collectionSockets){
						_collectionLayout.addSubject(subject);
					}
					if(_collectionLayoutSubject && super.layout){
						super.layout.addSubject(_collectionLayoutSubject);
					}
				}
			}
		}
		override public function get layout():ILayout{
			return super.layout;
		}
		override public function set layout(value:ILayout):void{
			if(super.layout!=value){
				if(_collectionLayoutSubject){
					if(super.layout){
						super.layout.removeSubject(_collectionLayoutSubject);
					}
					if(value){
						value.addSubject(_collectionLayoutSubject);
					}
				}
				super.layout = value;
			}
		}
		
		public function get collectionSocketId():String{
			return _socketCollContHelper.collectionSocketId;
		}
		public function set collectionSocketId(value:String):void{
			_socketCollContHelper.collectionSocketId = value;
		}
		public function get collectionPlugMappers():Array{
			return _socketCollContHelper.collectionPlugMappers;
		}
		public function set collectionPlugMappers(value:Array):void{
			_socketCollContHelper.collectionPlugMappers = value;
		}
		
		private var _collectionLayout:ILayout;
		private var _collectionLayoutSubject:ILayoutSubject;
		private var _socketCollContHelper:SocketCollectionContainerHelper;
		
		public function SocketCollectionContainer(asset:IDisplayAsset=null){
			super(asset);
		}
		override public function get childSockets(): Array{
			return _socketCollContHelper.allChildSockets;
		}
		override protected function get socketContHelper(): SocketContainerHelper{
			if(!_socketContHelper){
				_socketCollContHelper = new SocketCollectionContainerHelper(this,_childSocketsChanged);
				_socketCollContHelper.collectionSocketsChanged.addHandler(collectionSocketsChanged);
				_socketContHelper = _socketCollContHelper;
				_socketContHelper.defaultContainer = _childContainer;
			}
			return _socketContHelper;
		}
		protected function collectionSocketsChanged(added:Array, removed:Array): void{
			if(_collectionLayout){
				var subject:ILayoutSubject;
				for each(subject in removed){
					_collectionLayout.removeSubject(subject);
				}
				for each(subject in added){
					_collectionLayout.addSubject(subject);
				}
			}
		}
	}
}