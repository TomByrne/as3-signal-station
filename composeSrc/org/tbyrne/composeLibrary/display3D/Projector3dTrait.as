package org.tbyrne.composeLibrary.display3D
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.composeLibrary.display3D.types.I3dTo2dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.draw.types.IDrawAwareTrait;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.collections.IndexedList;
	
	public class Projector3dTrait extends AbstractTrait implements IDrawAwareTrait
	{
		public function get focalLength():INumberProvider{
			return _focalLength;
		}
		public function set focalLength(value:INumberProvider):void{
			if(_focalLength!=value){
				if(_focalLength){
					_focalLength.numericalValueChanged.removeHandler(onFocalLengthChanged);
				}
				_focalLength = value;
				invalidateAll();
				if(_focalLength){
					_focalLength.numericalValueChanged.addHandler(onFocalLengthChanged);
				}
			}
		}
		
		public function get matrix3dTrait():IMatrix3dTrait{
			return _matrix3dTrait;
		}
		public function set matrix3dTrait(value:IMatrix3dTrait):void{
			if(_matrix3dTrait!=value){
				if(_matrix3dTrait){
					_matrix3dTrait.matrix3dChanged.removeHandler(onMatrixChanged);
				}
				_matrix3dTrait = value;
				invalidateAll();
				if(_matrix3dTrait){
					_matrix3dTrait.matrix3dChanged.addHandler(onMatrixChanged);
				}
			}
		}
		
		private var _matrix3dTrait:IMatrix3dTrait;
		private var _focalLength:INumberProvider;
		
		
		private var _3dPositions:IndexedList;
		private var _3dInvalid:IndexedList;
		private var _3dAllInvalid:Boolean;
		
		public function Projector3dTrait(matrix3dTrait:IMatrix3dTrait=null, focalLength:INumberProvider=null){
			super();
			
			_3dPositions = new IndexedList();
			_3dInvalid = new IndexedList();
			
			addConcern(new Concern(false,true,false,I3dTo2dTrait,[I3dTo2dTrait]));
			
			this.matrix3dTrait = matrix3dTrait;
			this.focalLength = focalLength;
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.push(trait3d);
				trait3d.requestProjection.addHandler(on3dPositionChanged);
				if(!_3dAllInvalid)_3dInvalid.push(trait3d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var trait3d:I3dTo2dTrait;
			
			if(trait3d = (trait as I3dTo2dTrait)){ 
				_3dPositions.remove(trait3d);
				_3dInvalid.remove(trait3d);
				trait3d.requestProjection.removeHandler(on3dPositionChanged);
				//trait3d.setProjectedPoint(NaN,NaN,NaN,true);
				
			}
		}
		
		protected function on3dPositionChanged(from:I3dTo2dTrait, immediate:Boolean):void{
			if(immediate){
				validateList([from]);
				_3dInvalid.remove(from);
			}else{
				if(!_3dAllInvalid && !_3dInvalid.containsItem(from))_3dInvalid.push(from);
			}
		}
		
		protected function invalidateAll():void{
			if(!_3dAllInvalid){
				_3dAllInvalid = true;
				_3dInvalid.clear();
			}
		}
		
		
		
		public function tick(timeStep:Number):void{
			
			var invalid3dList:Array;
			if(_3dAllInvalid){
				_3dAllInvalid = false;
				invalid3dList = _3dPositions.list;
			}else if(_3dInvalid.list.length){
				invalid3dList = _3dInvalid.list;
				_3dInvalid.clear();
			}
			validateList(invalid3dList);
		}
		
		public function validateList(invalid:Array):void{
			var invMatrix:Matrix3D = _matrix3dTrait.invMatrix3d;
			var focalLength:Number = _focalLength.numericalValue;
			var i:int;
			var translate:Vector.<Number>;
			var output:Vector.<Number>;
			
			var pos3d:I3dTo2dTrait;
			
			if(invalid && invalid.length){
				if(invMatrix){
					translate = new Vector.<Number>();
					output = new Vector.<Number>();
					var readyTraits:Vector.<I3dTo2dTrait> = new Vector.<I3dTo2dTrait>();
					for each(pos3d in invalid){
						if(!isNaN(pos3d.x3d) && !isNaN(pos3d.y3d) && !isNaN(pos3d.z3d)){
							readyTraits.push(pos3d);
							translate.push(pos3d.x3d);
							translate.push(pos3d.y3d);
							translate.push(pos3d.z3d);
						}
					}
					invMatrix.transformVectors(translate, output);
					for(i=0; i<readyTraits.length; ++i){
						pos3d = readyTraits[i];
						project3dPoint(pos3d,focalLength,output[i*3],output[i*3+1],output[i*3+2]);
					}
				}else{
					for(i=0; i<invalid.length; ++i){
						pos3d = invalid[i];
						if(!isNaN(pos3d.x3d) && !isNaN(pos3d.y3d) && !isNaN(pos3d.z3d)){
							project3dPoint(pos3d,focalLength,pos3d.x3d,pos3d.y3d,pos3d.z3d);
						}
					}
				}
			}
		}
		
		private function project3dPoint(pos:I3dTo2dTrait, focalLength:Number, x:Number, y:Number, z:Number):void{
			if(focalLength<0){
				z = -z;
			}
			// NOTE: we switch the sign of the y value so that up is negative, down is positive (like most 3d engines)
			if(isNaN(focalLength) || focalLength==Number.POSITIVE_INFINITY || focalLength==Number.NEGATIVE_INFINITY){
				pos.setProjectedPoint(x, -y, 1, z);
			}else{
				var scale:Number = focalLength / (focalLength + z);
				pos.setProjectedPoint(x*scale, -y*scale, scale, z);
			}
		}
		
		
		private function onMatrixChanged(from:IMatrix3dTrait):void{
			invalidateAll();
		}
		private function onFocalLengthChanged(from:INumberProvider):void{
			invalidateAll();
		}
	}
}