package org.tbyrne.composeLibrary.display3D
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.I2dTo3dTrait;
	import org.tbyrne.composeLibrary.types.display3D.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	
	public class Unprojector3dTrait extends AbstractTrait implements IDrawAwareTrait
	{
		//private static const ROUND_REPROJECT_VALUES:int = 3; //decimal places
		private static const UP_VECTOR:Vector3D = new Vector3D(0,1,0);
		
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
		
		private var _2dPositions:IndexedList;
		private var _2dInvalid:IndexedList;
		private var _2dAllInvalid:Boolean;
		
		private var _dummyVector:Vector3D;
		
		public function Unprojector3dTrait(matrix3dTrait:IMatrix3dTrait=null, focalLength:INumberProvider=null){
			super();
			
			_2dPositions = new IndexedList();
			_2dInvalid = new IndexedList();
			_dummyVector = new Vector3D();
			
			addConcern(new Concern(false,true,I2dTo3dTrait,[I2dTo3dTrait]));
			
			this.matrix3dTrait = matrix3dTrait;
			this.focalLength = focalLength;
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.push(trait2d);
				trait2d.requestUnprojection.addHandler(on2dPositionChanged);
				if(!_2dAllInvalid)_2dInvalid.push(trait2d);
				
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var trait2d:I2dTo3dTrait;
			
			if(trait2d = (trait as I2dTo3dTrait)){
				_2dPositions.remove(trait2d);
				_2dInvalid.remove(trait2d);
				trait2d.requestUnprojection.removeHandler(on2dPositionChanged);
				//trait2d.setProjectedPoint(NaN, NaN, NaN, NaN);
				
			}
		}
		
		protected function on2dPositionChanged(from:I2dTo3dTrait):void{
			if(!_2dAllInvalid && !_2dInvalid.containsItem(from))_2dInvalid.push(from);
		}
		
		protected function invalidateAll():void{
			if(!_2dAllInvalid){
				_2dAllInvalid = true;
				if(_2dInvalid.list.length)_2dInvalid.clear();
			}
		}
		
		
		
		
		public function tick(timeStep:Number):void{
			var matrix:Matrix3D = _matrix3dTrait.matrix3d;
			var invMatrix:Matrix3D = _matrix3dTrait.invMatrix3d;
			var focalLength:Number = _focalLength.numericalValue;
			var i:int;
			var translate:Vector.<Number>;
			var output:Vector.<Number>;
			
			var invalid2dList:Array;
			if(_2dAllInvalid){
				_2dAllInvalid = false;
				invalid2dList = _2dPositions.list;
			}else if(_2dInvalid.list.length){
				invalid2dList = _2dInvalid.list;
				_2dInvalid.clear();
			}
			
			var pos2d:I2dTo3dTrait;
			var z2d:Number;
			
			if(invalid2dList && invalid2dList.length){
				var isFocalInf:Boolean = (focalLength==Number.POSITIVE_INFINITY || focalLength==Number.NEGATIVE_INFINITY);
				if(invMatrix){
					
					translate = new Vector.<Number>();
					output = new Vector.<Number>();
					var readyTraits:Vector.<I2dTo3dTrait> = new Vector.<I2dTo3dTrait>();
					for(i=0; i<invalid2dList.length; ++i){
						pos2d = invalid2dList[i];
						
						var x2d:Number;
						var y2d:Number;
						
						unprojectToPlane(pos2d,_dummyVector, matrix, isFocalInf);
						z2d = _dummyVector.z;
						
						if(isFocalInf){
							x2d = _dummyVector.x;
							y2d = _dummyVector.y;
						}else{
							var scale:Number = focalLength / (focalLength + z2d);
							x2d = _dummyVector.x*scale;
							y2d = _dummyVector.y*scale;
						}
						if(!isNaN(x2d) && !isNaN(y2d) && !isNaN(z2d)){
							readyTraits.push(pos2d);
							translate.push(x2d);
							translate.push(y2d);
							translate.push(z2d);
						}
					}
					invMatrix.transformVectors(translate, output);
					for(i=0; i<readyTraits.length; ++i){
						pos2d = readyTraits[i];
						/*var x:Number = roundTo(output[i*3], ROUND_REPROJECT_VALUES);
						var y:Number = roundTo(output[i*3+1], ROUND_REPROJECT_VALUES);
						var z:Number = roundTo(output[i*3+2], ROUND_REPROJECT_VALUES);
						
						
						pos2d.setUnprojectedPoint(x,y,z);*/
						pos2d.setUnprojectedPoint(output[i*3],output[i*3+1],output[i*3+2]);
					}
				}else{
					for(i=0; i<invalid2dList.length; ++i){
						pos2d = invalid2dList[i];
						//pos2d.setUnprojectedPoint(pos2d.x2d,pos2d.y2d,pos2d.cameraDistance);
						unprojectToPlane(pos2d,_dummyVector,null,isFocalInf);
						pos2d.setUnprojectedPoint(_dummyVector.x,_dummyVector.y,_dummyVector.z);
					}
				}
			}
		}
		
		private function unprojectToPlane(pos2d:I2dTo3dTrait, fillVector:Vector3D, matrix:Matrix3D, isFocalInfinite:Boolean):void{
			var planeTrans:IMatrix3dTrait = pos2d.planeTransform;
			if(planeTrans){
				
				
				
				//x = pos2d.x2d*(focalLength / (focalLength + z));
				//y = pos2d.y2d*(focalLength / (focalLength + z));
				
				//0 = -planeNormal.x*pos2d.x2d*(focalLength / (focalLength + z))-(planeNormal.x*planePos.x)-planeNormal.y*pos2d.y2d*(focalLength / (focalLength + z))-(planeNormal.y*planePos.y)-planeNormal.z*z-(planeNormal.z*planePos.z);
				
				var planeNormal:Vector3D = planeTrans.matrix3d.transformVector(UP_VECTOR);
				if(matrix)planeNormal = matrix.transformVector(planeNormal);
				
				var planePos:Vector3D = planeTrans.matrix3d.position;
				if(matrix)planePos = matrix.transformVector(planePos);
				
				/*planeNormal.z*(z-planePos.z) = -planeNormal.x*pos2d.x2d*(focalLength/(focalLength+z))-(planeNormal.x*planePos.x)
												-planeNormal.y*pos2d.y2d*(focalLength/(focalLength+z))-(planeNormal.y*planePos.y);
				*/
				
				
				
				
				var focalLength:Number = _focalLength.numericalValue;
				
				var a:Number = planeNormal.z;
				
				var b:Number = planePos.z;
				var c:Number = planeNormal.x;
				var d:Number = pos2d.x2d;
				var e:Number = pos2d.y2d;
				var f:Number = focalLength;
				var g:Number = planePos.x;
				var h:Number = planeNormal.y;
				var i:Number = planePos.y;
				
				var z:Number;
				if(isFocalInfinite){
					z = (-(c*d)-(c*g)-(h*e)-(h*i)-(a*b))/a;
				}else{
					var u:Number = a*f - a*b + c*g + h*i;
					var v:Number = f*(c*d + c*g + h*e + h*i - a*b);
					var w:Number = Math.abs(Math.pow(u,2) - 4*a*v);
					var z1:Number = (-u - Math.sqrt(w)) / (2*a);
					var z2:Number = (-u + Math.sqrt(w)) / (2*a);
					if(focalLength>0){
						z = z1>z2?z1:z2;
					}else{
						z = z1<z2?z1:z2;
					}
				}
				
				fillVector.x = pos2d.x2d;
				fillVector.y = pos2d.y2d;
				fillVector.z = z;
			}else{
				fillVector.x = pos2d.x2d;
				fillVector.y = pos2d.y2d;
				fillVector.z = pos2d.cameraDistance;
			}
		}
		
		
		protected function roundTo(number:Number, decimalPlace:int):Number{
			var multi:Number = Math.pow(10,decimalPlace);
			number *= multi;
			number = int(number+0.5);
			return number /=multi;
		}
		
		
		private function onMatrixChanged(from:IMatrix3dTrait):void{
			invalidateAll();
		}
		private function onFocalLengthChanged(from:INumberProvider):void{
			invalidateAll();
		}
	}
}