package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.DataGrid;

	public class FileHandler
	{
		/** 单例对象实例 */
		protected static var _instance:FileHandler;
		
		private var _fileList:ArrayCollection;
		private var _fileDataList:Array;
		private var _relativePath:String;
		private var _exportPath:String;
		
		public function FileHandler()
		{
			if (_instance != null)
				throw new Error("实例只能有一个");
			else
			{
				_fileList = new ArrayCollection();
				_fileDataList = [];
			}
		}
		
		/** 获取单例实例 */
		public static function getInstance():FileHandler
		{
			if (_instance == null)
				_instance = new FileHandler();
			
			return _instance;
		}
		
		/** 处理拖拽的文件，返回数据绑定datagrid */
		public function dropFileHandler(pFiles:Array):ArrayCollection
		{
			for each (var file:File in pFiles)
			{
				if (Common.fileIsAllow(file.extension) && !checkFileIsExistInList(file.name))
				{
					_fileList.addItem({
						filename: file.name,
						type: file.extension
					});
				}
			}
			return _fileList;
		}
		
		/** 检查文件是否存在 */
		private function checkFileIsExistInList(pFileName:String):Boolean
		{
			var result:Boolean = false;
			for each (var obj:Object in _fileList)
			{
				if (obj.filename == pFileName)
				{
					result = true;
					break;
				}
			}
			return result;
		}
		
		/**
		 * 文件是否在相对路径中
		 * @param pFiles 拖拽的文件
		 */
		public function checkDropFiles(pFiles:Array):Boolean
		{
			var result:Boolean = true;
			for each (var file:File in pFiles)
			{
				if (file.nativePath.indexOf(_relativePath) == -1)
				{
					result = false;
					break;
				}
			}
			return result;
		}
		
		
		/**
		 * 移除选定的文件 
		 * @param selectedFiles 选定的文件列表
		 */
		public function removeSelectedFiles(selectedFiles:Vector.<Object>):ArrayCollection
		{
			for each (var obj:Object in selectedFiles)
			{
				for (var i:int = 0; i < _fileList.length; i++)
				{
					if (obj.filename == _fileList.getItemAt(i).filename)
					{
						_fileList.removeItemAt(i);
						break;
					}
				}
			}
			return _fileList;
		}
		
		/** 清空所有文件 */
		public function clearAllFiles():ArrayCollection
		{
			while(_fileList.length > 0)
			{
				_fileList.removeItemAt(0);
			}
			return _fileList;
		}
		
		private var _exportCallback:Function;
		/** 导出文件 */
		public function export(pCallback:Function):void
		{
			_fileDataList = [];
			_exportCallback = pCallback;
			var len:int = _fileList.length;
			var file:File;
			var fileStream:FileStream;
			for (var i:int = 0; i < len; i++)
			{
				file = new File(_relativePath + _fileList[i].filename);
				fileStream = new FileStream();
				fileStream.open(file, FileMode.READ);				
				var fileContrent:String = fileStream.readMultiByte(file.size, "utf-8");
				saveDataList(file.name, _fileList[i].type, fileContrent);
				fileStream.close();
			}
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeObject(_fileDataList);
			byteArray.compress();
			FileUtil.browseAndSave(byteArray, _exportPath, "导出文件", onExportHandler);
		}
		
		/** 导出文件回调 */
		private function onExportHandler(file:File):void
		{
			_exportPath = file.nativePath;
			_exportCallback(file.nativePath);
			Common.saveCookie(Common.COOKIE_NAME_EXPORT, file.nativePath);
		}
		
		/** 保存文件实例到数据列表中 */
		private function saveDataList(pName:String, pType:String, pContent:String):void
		{
			var configFile:Object = {};
			configFile.name = pName;
			configFile.type = pType;
			
			switch (pType)
			{
				case Common.TYPE_XML:
					configFile.content = new XML(pContent);
					break;
				
				case Common.TYPE_JSON:
					configFile.content = JSON.parse(pContent);
					break;
				
				case Common.TYPE_TXT:
					configFile.content = pContent;
					break;
			}
			
			_fileDataList.push(configFile);
		}
		
		/**
		 * 打开导出的文件并解析文件内容返回列表绑定信息 
		 * @param pPath 导出文件的路径
		 */
		public function openExportFile(pPath:String):ArrayCollection
		{
			var byteArray:ByteArray = FileUtil.openAsByteArray(pPath);
			if (byteArray)
			{
				parseExportFile(byteArray);
				return _fileList;
			}
			else
			{
				return new ArrayCollection();
			}
		}
		
		/** 解析导出的文件 */
		private function parseExportFile(pByteArray:ByteArray):void
		{
			pByteArray.uncompress();
			var fileDataList:Array = pByteArray.readObject() as Array;
			for each (var obj:Object in fileDataList)
			{
				if (!checkFileIsExistInList(obj.name))
				{
					_fileList.addItem({
						filename: obj.name,
						type: obj.type
					});
				}
				
			}
		}
		
		private var _importCallback:Function;
		/** 导入配置压缩文件 */
		public function importFile(pCallback:Function):void
		{
			_fileList = new ArrayCollection();
			_importCallback = pCallback;
			FileUtil.browseForOpen(onImportSelect, 1, null, "导入配置压缩文件");
		}
		
		/** 导入配置压缩文件回调处理 */
		private function onImportSelect(pFile:File):void
		{
			var fs:FileStream = new FileStream();
			fs.open(pFile, FileMode.READ);
			var byteArray:ByteArray = new ByteArray();
			fs.readBytes(byteArray, 0, pFile.size);
			fs.close();
			parseExportFile(byteArray);
			_importCallback(_fileList);
		}
		
		/** 检查文件是否存在 */
		public function checkFileIsExist(pFilePath:String):Boolean
		{
			return FileUtil.exists(_relativePath + pFilePath);
		}
		
		/** 相对路径 */
		public function set relativePath(value:String):void
		{
			_relativePath = value;
		}
		
		/** 相对路径 */
		public function get relativePath():String
		{
			return _relativePath;
		}

		public function set exportPath(value:String):void
		{
			_exportPath = value;
		}

		
	}
}