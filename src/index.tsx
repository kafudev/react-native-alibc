import { NativeModules } from 'react-native';

type AlibcType = {
  multiply(a: number, b: number): Promise<number>;
};

const { Alibc } = NativeModules;

export default Alibc as AlibcType;
