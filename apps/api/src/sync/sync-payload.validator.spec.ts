import { assertEntityType, validatePayload } from './sync-payload.validator';

describe('sync payload validator', () => {
  it('rejects health and imported calendar entity types', () => {
    expect(() => assertEntityType('health')).toThrow();
    expect(() => assertEntityType('importedCalendarEvent')).toThrow();
  });

  it('requires minor-unit money strings', () => {
    expect(() =>
      validatePayload('financeTransaction', 'create', {
        amountMinor: 12.5,
        currencyCode: 'PKR',
      }),
    ).toThrow();
    expect(
      validatePayload('financeTransaction', 'create', {
        amountMinor: '1250',
        currencyCode: 'PKR',
      }),
    ).toMatchObject({ amountMinor: '1250' });
  });

  it('rejects local wardrobe paths', () => {
    expect(() =>
      validatePayload('wardrobeItem', 'create', {
        localImagePath: '/var/mobile/item.png',
      }),
    ).toThrow();
  });

  it('rejects imported calendar identifiers', () => {
    expect(() =>
      validatePayload('memyCalendarEvent', 'create', {
        title: 'Dinner',
        externalEventId: 'device-link',
      }),
    ).toThrow();
  });
});
