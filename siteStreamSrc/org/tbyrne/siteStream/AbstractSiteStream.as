package org.tbyrne.siteStream
{
	import flash.display.*;
	import flash.net.*;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.memory.garbageCollect;
	import org.tbyrne.siteStream.parsers.ISiteStreamParser;
	import org.tbyrne.siteStream.parsers.ParserProxy;
	
	use namespace SiteStreamNamespace;
	
	// TODO: Error reporting which includes which file the offending text is in
	// TODO: Track which namespaces are and aren't used in an xml file and display
	// a trace warning if there are some that aren't
	public class AbstractSiteStream
	{
		/**
		 * handler(from:AbstractSiteStream)
		 */
		public function get dataLoadFailure():IAct{
			return (_dataLoadFailure || (_dataLoadFailure = new Act()));
		}
		
		/**
		 * handler(from:AbstractSiteStream)
		 */
		public function get classLoadFailure():IAct{
			return (_classLoadFailure || (_classLoadFailure = new Act()));
		}
		/**
		 * handler(from:AbstractSiteStream, path:String)
		 */
		public function get beginResolve():IAct{
			return (_beginResolve || (_beginResolve = new Act()));
		}
		
		/**
		 * handler(from:AbstractSiteStream, path:String)
		 */
		public function get completeResolve():IAct{
			return (_completeResolve || (_completeResolve = new Act()));
		}
		
		protected var _completeResolve:Act;
		protected var _beginResolve:Act;
		protected var _classLoadFailure:Act;
		protected var _dataLoadFailure:Act;
		
		
		// testing
		public function get nodeCount():int{
			return countDescendants(rootNode)+1;
		}
		protected function countDescendants(node:SiteStreamNode):int{
			var ret:int = 0;
			var iterator:IIterator = node.getChildIterator();
			var child:SiteStreamNode;
			while(child = iterator.next()){
				ret++;
				ret += countDescendants(child);
			}
			iterator.release();
			return ret;
		}
		public function get siteStreamParser():ISiteStreamParser{
			return _defaultItem.siteStreamItem;
		}
		public function set siteStreamParser(value:ISiteStreamParser):void{
			if(_defaultItem.siteStreamItem!=value){
				_defaultItem.siteStreamItem = value;
			}
		}
		public function get rootObject():Object{
			return _rootNode.propertyInfo.value;
		}
		SiteStreamNamespace function set rootNode(value:SiteStreamNode):void{
			if(_rootNode!=value){
				if(_rootNode){
					_rootNode.wasParsed.removeHandler(onRootLoaded);
				}
				_rootNode = value;
				if(_rootNode){
					_rootNode.wasParsed.addHandler(onRootLoaded);
				}
			}
		}
		SiteStreamNamespace function get rootNode():SiteStreamNode{
			return _rootNode;
		}
		
		private var _defaultItem:ParserProxy = new ParserProxy();
		private var _rootNode:SiteStreamNode;
		private var _pendingNodeResolvers:Array = [];
		
		public function AbstractSiteStream(){
			_defaultItem.classLoadFailure.addHandler(onClassLoadFailure);
			_defaultItem.dataLoadFailure.addHandler(onDataLoadFailure);
		}
		private function onDataLoadFailure(from:ISiteStreamParser):void{
			if(_dataLoadFailure)_dataLoadFailure.perform(this);
		}
		private function onClassLoadFailure(from:ISiteStreamParser):void{
			if(_classLoadFailure)_classLoadFailure.perform(this);
		}
		public function isObjectLoaded(path:String):Boolean{
			if(_rootNode){
				var nodeResolver:NodeResolver = new NodeResolver(_rootNode,path);
				return nodeResolver.loaded;
			}else{
				return false;
			}
		}
		public function isRootLoaded():Boolean{
			return isObjectLoaded("");
		}
		public function getPath(object:Object):String{
			return _getPath(object,_rootNode);
		}
		private function _getPath(object:Object, node:SiteStreamNode, path:String=null):String{
			if(node==_rootNode)path = "";
			else path += (path.length?"/":"")+node.id;
			
			if(node.propertyInfo.value==object){
				return path;
			}else{
				var iterator:IIterator = node.getChildIterator();
				var child:SiteStreamNode;
				var ret:String;
				while(child = iterator.next()){
					var childPath:String = _getPath(object, child, path);
					if(childPath){
						ret = childPath;
						break;
					}
				}
				iterator.release();
				return ret;
			}
			return null;
		}
		public function getObject(path:String, success:Function):void{
			if(_beginResolve)_beginResolve.perform(this,path);
			var nodeResolver:NodeResolver = new NodeResolver(_rootNode,path);
			nodeResolver.wasResolved.addHandler(createObjectHandler(success));
			nodeResolver.wasResolved.addHandler(onNodeResolved);
			if(_rootNode){
				nodeResolver.load();
			}else{
				_pendingNodeResolvers.push(nodeResolver);
			}
		}
		
		protected function onNodeResolved(nodeResolver:NodeResolver, value:*):void{
			nodeResolver.wasResolved.removeHandler(onNodeResolved);
			if(_completeResolve)_completeResolve.perform(this,nodeResolver.path);
		}
		public function releaseObject(path:String):void{
			var nodeResolver:NodeResolver = new NodeResolver(_rootNode,path);
			if(nodeResolver.loaded){
				nodeResolver.node.releaseObject();
				garbageCollect();
			}
		}
		public function getRoot(success:Function/*, failure:Function=null*/):void{
			getObject("",success/*,failure*/);
		}
		private function createObjectHandler(handler:Function):Function{
			return function(from:NodeResolver, value:*):void{
				handler(value);
			}
		}
		protected function onRootLoaded(from:SiteStreamNode):void{
			_rootNode.wasParsed.removeHandler(onRootLoaded);
			this.resolvePendingNodes();
		}
		
		protected function resolvePendingNodes(): void{
			while (this._pendingNodeResolvers.length > 0){
				var nodeResolver: NodeResolver = this._pendingNodeResolvers.pop() as NodeResolver;
				nodeResolver.load();
			}
		}
	}
}



/**

NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNmmmmmmmmmmmmmmmddmmmmmmmmmmmmmmmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmdddddddddddddddddddmmmmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmmmmmddddddddddddddddddddddddddddddddmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNddddddddddddddhhdhhhhhhhhhdhhhhddddddddddddmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmdddddddhhhhhhdhhhhhhhhhhhhhhhdhhdddddddddmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNNNNNmNNmdddddhhhhhhyymdyyyyyyhhhyyyhhhhhhhhhhhddddmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNmNNmNNNNNNmdNmhddhhhhyyyyyyddhyyyyyyyyyyyyyhhhhhhhhhhhhdddmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNmNNmNNNNNmmdNmddddhhyyyyyyyhymdsyyyyyyyyyyyyyyyyyhhhhhhdddmdmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNmmNmNNNNNmddmdhddhhhyyysssshsddssssyyssssssysyyyyyyyyyhhdddddmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNmmmNmNNmmdyo++++oooossssssssysddssssssssssssssyyyyyyyyyhhhhdddmdmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNmmmNmmmdhso/::::------/oooooyohdooooosoossssssssssssysyyyhhhddddmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNmdhyso+/:::----...--++++s+ooooooooooooossssssssssssyyhhhhdddmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNmdhyssoo//:---.......-:/+oo+oo+++oooooosooooooosssssyyyyhhhdddmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNmddhyoo+++/:--.........-//o++//++++ooooooooooooooososyyyyyhhddddmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNmmdhyso++///:-...........:/o/:-/+//++++++ooooooooooosssyyyyhhdddddmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNmdhysoo++//::-..........-oss/-:o////+++++++oooooooooosssyyyhhdddddmNNNNmNNNmmNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNmdysoo++///:-::::--....-/+:--/o////+++++++oooooooooossyyyyhddddddmNNNNmmmNNmmmmNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNmdys++/////oys+/--.....---/osyo+++++++++oooooooooosssyyyhdddddddmNNmmmmmmNmNmmNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdys++//+ysso+:--.....--/yhhddhyyyyyhhhhhhhyyyysssyyyhhdddddddmmmmNmmNmNmNNmNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmdhs+::oso+/----..----/yhdddmmddddddmmdmmdddddddmmdhhdddddddmmmmmmNNNNmNmmmmmmmmmNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNdddmy/::+oo+:--------/yddmmmmNmmmmmmmmmmmmmmmmmmNNNmdhhddddmmNNNNmdddhhhhyyyyhhhhddmmmmmmmmNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNmmmmh/:------------/oydmmmmNmmNNmmmmNmmmmmmNNmmNNNmmddhhdmmmmdddddddddhdddddddddddddmmmmmddmmmmNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNmddmmmdo:------------/yhdmmmNNNmmNNmNNNNmNNNNNNNNNNNmdhhhdmmmdmmmmdmdddmdmmmmmmmmmNNNNNNmNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdmmmy/:---:-----::+hhdmNNNNNNmmNNNNNNNNNNNNNNNNNNNmdhhdmmNNmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNmms//:------:::sdddmNNNNNNNmNNNNNNNNNNNNNNNNNNNNddhdNmmNmNmdmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmhyso/+//:::::+hddmmNNNNNNNNmNNNNNNNNNNNNNNNNNNNmdhmNmmNmNNddddmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmddmssyo/::::+hdmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNdNNmmNmNNdddmNNNmNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdyso/////ohmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNmNNmmNNddmmNNNmmmmNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNdhyso+++ydmNNNNNNNNNNNNNNNNmNNNNNNNNNNNNNNNNNNNNmNNNNNNmmmNNNmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNN
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmdhhhhhmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNNNNmmmmmmmmNNNNNNNNNNNNNNNNNNN
NNNNmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmNNNNNNNNNNNNNNNN
NNNmhhyoossssyhhdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNNmmmmmNNNNNNNNNNNNNN
NNmhyyyyysoosyhsoymNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNmhysyddhs++yddyydmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNNNhsoymNmyo+ymNNNmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNNNNNNNNN
NmmNNmhsosmNmy++hmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmNNNNNNNNN
NmdmNNNmyosdNmhssdNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmNNNNNNNNN
NNmdmmNNmyoohNNNdhNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
NNNmdhhdmNmhshNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmNmNNNNNmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
mmmmNNmmhdNNNmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmdddhyssoo+oossyhhhhddddddddddmmmmmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
hyyssyhdmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmdhhsoso+///:::--------:::::::::://+osyhhddmmmmmmNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
dhyyso++++++oossyhdmmNNNNNNNNNNNNNNNNNNNNNmmmddyo/:::::------------...---.--------------://+syhhdddddmmmNNNNNNNNNNNNNNNNNNNNNNNNNN
ddysoo++///:::::::/+syddmmmNNNNNNNNNNNmmmdhys+/:::-----------..........................--------::::://++shmmmNNNNNNNNNNNNNNNNNNNNN
hysoo++//::::::::::::::/+shdmmNNNNNNmmmho//:::---------.................................--....--------://sdmmNNNNNNNNNNNNmhhhhhhhh
mddhyyso++////:::-:::::::::+ydmmmmddhyo/:::----------...-................................-....-------:::/hdmmNNNNNNNNNNNNy++++osyy
NNmmdhyso+/++::::--:------:::ohdyydhso+/:---------------.................................--...------::::odmmmmmmmmmNNNNNmo//+osyyh
NNNmdhyhyyoo+//::-:----------:oshdysso//:------..-------.................................-....-:----:/:/ydddddhyyssyhdmmdssyhyssyh
NNNNNmdhyso+++/////::::-------:+hs+oso//:::-------------......-----.......---.........---------:---:///ohdyhhyssooosyddhhdhoo+shhh
NNNNNNNmmhyyyssso++///::::-----:/+osso+++/:::-------::---..-----::--..----------------------:::/:::/+osyhyyhhsyhyhdmmmmmy+++syhddd
NNNNNNNNmmddhyysoo++/////:::::::::oyysooo++///:::::::::------:::/::---::::::::::::-::::::::://+o+/+shhhdmmmmdmmmmmmmmmds++oshhdddm

                     88  88  88           88              
                     88  ""  88           88              
                     88      88           88              
 ,adPPYba,   ,adPPYb,88  88  88,dPPYba,   88   ,adPPYba,  
a8P_____88  a8"    `Y88  88  88P'    "8a  88  a8P_____88  
8PP"""""""  8b       88  88  88       d8  88  8PP"""""""  
"8b,   ,aa  "8a,   ,d88  88  88b,   ,a8"  88  "8b,   ,aa  
 `"Ybbd8"'   `"8bbdP"Y8  88  8Y"Ybbd8"'   88   `"Ybbd8"'  
                                                          
                                                          
                                                                          
   ad88              88                                    88             
  d8"                ""                                    88             
  88                                                       88             
MM88MMM  8b,dPPYba,  88   ,adPPYba,  8b,dPPYba,    ,adPPYb,88  ,adPPYba,  
  88     88P'   "Y8  88  a8P_____88  88P'   `"8a  a8"    `Y88  I8[    ""  
  88     88          88  8PP"""""""  88       88  8b       88   `"Y8ba,   
  88     88          88  "8b,   ,aa  88       88  "8a,   ,d88  aa    ]8I  
  88     88          88   `"Ybbd8"'  88       88   `"8bbdP"Y8  `"YbbdP"' 
  
  					  _    _    _     _    _    _    _    _    _    _    _    _    _    _    _    _    _
					 / \  / \  / \   / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \  / \
					( T )( h )( e ) ( H )( i )( e )( r )( a )( r )( c )( h )( i )( t )( e )( c )( t )( s )
					 \_/  \_/  \_/   \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/  \_/ 

**/