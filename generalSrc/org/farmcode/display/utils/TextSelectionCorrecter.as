package org.farmcode.display.utils
{
	import flash.text.TextField;
	
	import org.farmcode.diff.Common;
	import org.farmcode.diff.Diff;
	import org.farmcode.diff.Difference;

	/**
	 * TextSelectionCorrecter corrects user selection indices when a block
	 * of text is edited/formatted by code.
	 */
	public class TextSelectionCorrecter
	{
		public function TextSelectionCorrecter(){
		}
		
		public function setText(textField:TextField, text:String) : void{
			if(textField.text!=text){
				var diff:Array = Diff.executeByCharacter(textField.text,text);
				var oldBegin:int = textField.selectionBeginIndex;
				var oldEnd:int = textField.selectionEndIndex;
				var newBegin:int;
				var newEnd:int;
				var oldCount:int = 0;
				var newCount:int = 0;
				for each(var match:* in diff){
					var common:Common = (match as Common);
					var matchSize:int;
					var newSize:int;
					if(common){
						matchSize = newSize = common.common.length;
					}else{
						var difference:Difference = (match as Difference);
						matchSize = difference.file1.length
						newSize = difference.file2.length;
					}
					if(oldBegin==oldCount+matchSize){
						newBegin = newCount+matchSize;
					}else if(oldBegin<oldCount+matchSize){
						newBegin = newCount+Math.round(((oldBegin-oldCount)/matchSize)*newSize);
					}
					if(oldEnd==oldCount+matchSize){
						newEnd = newCount+matchSize;
					}else if(oldEnd<oldCount+matchSize){
						newEnd = newCount+Math.round(((oldEnd-oldCount)/matchSize)*newSize);
						break;
					}
					oldCount += matchSize;
					newCount += newSize;
				}
				textField.text = text;
				textField.setSelection(newBegin,newEnd);
			}
		}
	}
}