package au.com.thefarmdigital.delayedDraw
{
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.DictionaryUtils;
	import org.farmcode.core.DelayedCall;
	
	public class DelayedDrawer
	{
		/**
		 * @private
		 */
		protected static const invalid:Dictionary = new Dictionary(true);
		/**
		 * @private
		 */
		protected static var invalidateCall: DelayedCall = new DelayedCall(doDraw,1,false);
		/**
		 * @private
		 */
		protected static var executingDraw:Boolean;
		/**
		 * @private
		 */
		protected static var executingDrawRoots:Dictionary;
		/**
		 * @private
		 */
		protected static var executingInvalid:Dictionary;
		/**
		 * @private
		 */
		protected static var drawingNow:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 
		 * When a view gets removed from the stage while we are drawing it should also be removed
		 * from the currently executing draw list (along with it's children).
		 * This transfers views from the currently executing draw list back to the main invalid list
		 * (to make sure that when they're added back to the stage they'll still get drawn).
		 * 
		 */
		public static function removeDrawable(drawable:IDrawable):void{
			if(executingDraw){
				findDescendants(drawable,executingInvalid,false,true);
				delete executingInvalid[drawable];
			}
		}
		/**
		 * @private
		 * 
		 * This adds/removes views from either the currently executing draw list or the main invalid list.
		 */
		public static function changeValidity(drawable:IDrawable, value:Boolean):void{
			if(executingDraw){
				if(value){
					delete executingInvalid[drawable];
					return;
				}else if(drawable.readyForDraw && isDescendant(executingDrawRoots,drawable)){
					executingInvalid[drawable] = true;
					invalid[drawable] = true;
					return;
				}
			}
			if(!value){
				invalid[drawable] = true;
				invalidateCall.begin();
			}else{
				delete invalid[drawable];
			}
		}
		/**
		 * @private
		 */
		public static function checkValidity(drawable:IDrawable):Boolean{
			return (invalid[drawable]!=true);
		}
		/**
		 * @private
		 * 
		 * This executes a draw list by first isolating all views that should be drawn,
		 * then looping through them and drawing them. Views will only be drawn if they are
		 * on the stage or their validate method gets called (although their validity will
		 * still be tracked).
		 */
		public static function doDraw(root:IDrawable=null):void{
			if(root && (checkValidity(root) || drawingNow[root])){
				return;
			}
			var i:*
			var drawable:IDrawable;
			if(executingDraw){
				if(!root){
					executingDrawRoots = null;
				}else{
					if(!executingDrawRoots){
						executingDrawRoots = new Dictionary(true);
					}
					
					executingDrawRoots[root] = true;
					var newInvalidDescendants: Dictionary = findDescendants(root,invalid,true,false);
					executingInvalid = DictionaryUtils.merge(executingInvalid, newInvalidDescendants, false);
					
					drawingNow[root] = true;
					invalid[root] = true;
					root.commitDraw();
					delete invalid[root];
					delete executingInvalid[root];
					delete drawingNow[root];
				}
			}else{
				executingDraw = true;
				if(root){
					if (executingDrawRoots == null)
					{
						executingDrawRoots = new Dictionary(true);
					}
					executingDrawRoots[root] = true;
				}else executingDrawRoots = null;
				
				executingInvalid = findDescendants(root,invalid,true,false);
				if(root){
					root.commitDraw();
					delete invalid[root];
					delete executingInvalid[root];
				}
				var stop:Boolean = false;
				while(!stop){
					stop = true;
					for(i in executingInvalid){
						stop = false;
						drawable = (i as IDrawable);
						drawingNow[drawable] = true;
						drawable.commitDraw();
						delete invalid[drawable];
						delete executingInvalid[drawable];
						delete drawingNow[drawable];
					}
				}
				if(!invalidateCall.running){
					for(i in invalid){
						invalidateCall.begin();
						break;
					}
				}
				executingInvalid = null;
				executingDraw = false;
				executingDrawRoots = null;
			}
		}
		/**
		 * @private
		 */
		protected static function isDescendant(roots:Dictionary, drawable:IDrawable):Boolean{
			if(!roots)return true; // if this is a frame based execution
			for(var root:* in roots){
				var castDisplay:DisplayObjectContainer = (root as IDrawable).drawDisplay as DisplayObjectContainer;
				if(castDisplay && drawable.drawDisplay && DisplayUtils.isDescendant(castDisplay, drawable.drawDisplay)){
					return true;
				}
			}
			return false;
		}
		/**
		 * @private
		 * 
		 */
		protected static function findDescendants(root:IDrawable, collection:Dictionary, onlyReady:Boolean, remove:Boolean):Dictionary{
			var ret:Dictionary = new Dictionary(true);
			var castDisplay:DisplayObjectContainer;
			if(root){
				castDisplay = root.drawDisplay as DisplayObjectContainer;
				if(!castDisplay){
					return ret;
				}
			}
			if(!root || (root.readyForDraw || !onlyReady)){
				for(var obj:* in collection){
					var view:IDrawable = (obj as IDrawable);
					var stage:Boolean = ((view.readyForDraw) || !onlyReady);
					if(view!=root || stage){
						if(stage && (!root || (view.drawDisplay && (castDisplay==view.drawDisplay || DisplayUtils.isDescendant(castDisplay,view.drawDisplay))))){
							ret[view] = true;
							if(remove){
								delete collection[obj];
							}
						}
					}
				}
			}
			//if(root)ret[root] = true;
			return ret;
		}
	}
}