package org.farmcode.display.utils
{
	import flash.text.TextField;
	
	import org.farmcode.diff.Common;
	import org.farmcode.diff.Diff;
	import org.farmcode.diff.Difference;
	import org.farmcode.display.assets.assetTypes.ITextFieldAsset;

	/**
	 * TextSelectionCorrecter corrects user selection indices when a block
	 * of text is edited/formatted by code.
	 */
	public class TextSelectionCorrecter
	{
		public function TextSelectionCorrecter(){
		}
		
		public function setText(textField:ITextFieldAsset, toText:String, fromText:String=null, currSelBeginIndex:int=-1, currSelEndIndex:int=-1) : void{
			if(textField.text!=toText){
				var oldText:String = fromText?fromText:textField.text;
				var oldBegin:int = currSelBeginIndex==-1?textField.selectionBeginIndex:currSelBeginIndex;
				var oldEnd:int = currSelEndIndex==-1?textField.selectionEndIndex:currSelEndIndex;
				
				var newBegin:int;
				var newEnd:int;
				if(oldBegin==oldEnd && oldBegin==oldText.length){
					newBegin = newEnd = toText.length;
				}else{
					var diff:Array = Diff.executeByCharacter(oldText,toText);
					newBegin = -1;
					newEnd = -1;
					var oldCount:int = 0;
					var newCount:int = 0;
					for each(var match:* in diff){
						var common:Common = (match as Common);
						var matchSize:int;
						var newSize:int;
						var fract:Number;
						if(common){
							matchSize = newSize = common.common.length;
						}else{
							var difference:Difference = (match as Difference);
							matchSize = difference.file1.length
							newSize = difference.file2.length;
						}
						if(newBegin==-1){
							if(common){
								if(oldBegin<=oldCount+matchSize){
									newBegin = newCount+(oldBegin-oldCount);
								}
							}else if(oldBegin<=oldCount+newSize){
								if(matchSize){
									fract = ((oldBegin-oldCount)/matchSize);
								}else{
									fract = 0.5;
								}
								newBegin = newCount+Math.round(fract*newSize);
							}
						}
						if(newEnd==-1){
							if(common){
								if(oldEnd<=oldCount+matchSize){
									newEnd = newCount+(oldEnd-oldCount);
								}
							}else if(oldEnd<=oldCount+newSize){
								if(matchSize){
									fract = ((oldEnd-oldCount)/matchSize);
								}else{
									fract = 0.5;
								}
								newEnd = newCount+Math.round(fract*newSize);
							}
						}
						oldCount += matchSize;
						newCount += newSize;
					}
				}
				textField.text = toText;
				textField.setSelection(newBegin,newEnd);
			}
		}
	}
}