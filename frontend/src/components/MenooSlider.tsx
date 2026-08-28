import React, { useRef, useState } from 'react';
import { View, StyleSheet, PanResponder, LayoutChangeEvent } from 'react-native';
import { colors, radius } from '../theme/tokens';

interface Props {
  value: number;
  min?: number;
  max: number;
  step?: number;
  onChange: (v: number) => void;
  testID?: string;
}

export default function MenooSlider({ value, min = 0, max, step = 1, onChange, testID }: Props) {
  const [width, setWidth] = useState(0);
  const widthRef = useRef(0);

  const onLayout = (e: LayoutChangeEvent) => {
    const w = e.nativeEvent.layout.width;
    setWidth(w);
    widthRef.current = w;
  };

  const applyFromX = (x: number) => {
    const w = widthRef.current;
    if (w <= 0) return;
    const ratio = Math.max(0, Math.min(1, x / w));
    let next = min + ratio * (max - min);
    next = Math.round(next / step) * step;
    next = Math.max(min, Math.min(max, next));
    onChange(next);
  };

  const responder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (e) => applyFromX(e.nativeEvent.locationX),
      onPanResponderMove: (_e, g) => applyFromX(g.moveX - g.x0 + (_e.nativeEvent.locationX)),
    })
  ).current;

  const ratio = max === min ? 0 : (value - min) / (max - min);
  const fillWidth = Math.max(0, Math.min(1, ratio)) * width;
  const thumbLeft = Math.max(0, Math.min(width - 28, fillWidth - 14));

  return (
    <View
      testID={testID}
      style={styles.wrap}
      onLayout={onLayout}
      {...responder.panHandlers}
    >
      <View style={styles.track} />
      <View style={[styles.fill, { width: fillWidth }]} />
      <View style={[styles.thumb, { left: thumbLeft }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { height: 44, justifyContent: 'center' },
  track: {
    height: 10,
    borderRadius: radius.pill,
    backgroundColor: colors.brandSecondaryMuted,
  },
  fill: {
    position: 'absolute',
    left: 0,
    height: 10,
    borderRadius: radius.pill,
    backgroundColor: colors.brandPrimary,
  },
  thumb: {
    position: 'absolute',
    top: 8,
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.surfaceSecondary,
    borderWidth: 3,
    borderColor: colors.brandPrimary,
    shadowColor: '#000',
    shadowOpacity: 0.12,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
    elevation: 3,
  },
});
